using UnityEngine;

/// <summary>
/// 敌人AI - 巡逻/警戒/战斗状态机
/// 敌人类型: 川军/黔军/中央军/滇军
/// </summary>
[RequireComponent(typeof(NavMeshAgent))]
public class EnemyAI : MonoBehaviour
{
    public enum EnemyState
    {
        Patrolling,   // 巡逻
        Alerted,      // 警戒
        Combat,       // 战斗
        Retreat       // 撤退
    }

    [Header("敌人类型")]
    public string enemyType = "川军士兵";
    public float patrolSpeed = 2f;
    public float chaseSpeed = 4f;
    public float attackRange = 20f;
    public float attackDamage = 8f;
    public float attackInterval = 2f;
    public float detectionRange = 15f;
    public float loseTargetRange = 25f;

    [Header("巡逻点")]
    public Transform[] patrolPoints;
    public bool patrolLoop = true;

    [Header("引用")]
    public EnemyHealth health;
    public Transform player;

    private NavMeshAgent agent;
    private EnemyState currentState;
    private int patrolIndex = 0;
    private float lastAttackTime = 0f;

    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        if (health == null)
            health = GetComponent<EnemyHealth>();

        GameObject playerObj = GameObject.FindGameObjectWithTag("Player");
        if (playerObj != null)
            player = playerObj.transform;

        ChangeState(EnemyState.Patrolling);
    }

    void Update()
    {
        if (health != null && health.isDead)
        {
            agent.isStopped = true;
            return;
        }

        switch (currentState)
        {
            case EnemyState.Patrolling:
                Patrol();
                break;
            case EnemyState.Alerted:
                Alerted();
                break;
            case EnemyState.Combat:
                Combat();
                break;
            case EnemyState.Retreat:
                Retreat();
                break;
        }
    }

    void ChangeState(EnemyState newState)
    {
        currentState = newState;

        switch (newState)
        {
            case EnemyState.Patrolling:
                agent.speed = patrolSpeed;
                if (patrolPoints.Length > 0)
                    agent.SetDestination(patrolPoints[patrolIndex].position);
                break;
            case EnemyState.Alerted:
                agent.speed = patrolSpeed;
                break;
            case EnemyState.Combat:
                agent.speed = chaseSpeed;
                break;
            case EnemyState.Retreat:
                agent.speed = chaseSpeed;
                break;
        }
    }

    void Patrol()
    {
        if (patrolPoints.Length == 0) return;

        if (!agent.pathPending && agent.remainingDistance < 0.5f)
        {
            patrolIndex++;
            if (patrolIndex >= patrolPoints.Length)
            {
                if (patrolLoop)
                    patrolIndex = 0;
                else
                    return;
            }
            agent.SetDestination(patrolPoints[patrolIndex].position);
        }

        if (player != null)
        {
            float dist = Vector3.Distance(transform.position, player.position);
            if (dist < detectionRange)
            {
                ChangeState(EnemyState.Combat);
            }
        }
    }

    void Alerted()
    {
        if (player != null)
        {
            float dist = Vector3.Distance(transform.position, player.position);
            if (dist < detectionRange)
            {
                ChangeState(EnemyState.Combat);
            }
            else if (dist > loseTargetRange)
            {
                ChangeState(EnemyState.Patrolling);
            }
        }
    }

    void Combat()
    {
        if (player == null) return;

        float dist = Vector3.Distance(transform.position, player.position);

        if (dist > loseTargetRange)
        {
            ChangeState(EnemyState.Alerted);
            return;
        }

        if (dist > attackRange)
        {
            agent.SetDestination(player.position);
        }
        else
        {
            agent.isStopped = true;
            transform.LookAt(player);

            if (Time.time - lastAttackTime >= attackInterval)
            {
                Attack();
                lastAttackTime = Time.time;
            }
        }
    }

    void Retreat()
    {
        if (patrolPoints.Length > 0)
        {
            agent.SetDestination(patrolPoints[0].position);
        }
    }

    void Attack()
    {
        Debug.Log($"{enemyType} 攻击玩家，造成 {attackDamage} 伤害");

        PlayerHealth playerHealth = player.GetComponent<PlayerHealth>();
        if (playerHealth != null)
        {
            float hitChance = Mathf.Clamp01(1f - Vector3.Distance(transform.position, player.position) / attackRange);
            if (Random.value < hitChance * 0.6f)
            {
                playerHealth.TakeDamage(attackDamage);
            }
        }
    }

    public void OnHitAlert(Vector3 soundPosition)
    {
        if (currentState == EnemyState.Patrolling)
        {
            ChangeState(EnemyState.Alerted);
            agent.SetDestination(soundPosition);
        }
    }
}
