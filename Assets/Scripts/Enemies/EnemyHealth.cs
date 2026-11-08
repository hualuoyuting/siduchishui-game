using UnityEngine;
using UnityEngine.Events;

/// <summary>
/// 敌人生命系统
/// </summary>
public class EnemyHealth : MonoBehaviour
{
    [Header("生命设置")]
    public float maxHealth = 60f;
    public float currentHealth;

    [Header("事件")]
    public UnityEvent OnDamaged;
    public UnityEvent OnDeath;

    public bool isDead = false;

    void Start()
    {
        currentHealth = maxHealth;
    }

    public void TakeDamage(float damage)
    {
        if (isDead) return;

        currentHealth -= damage;
        OnDamaged?.Invoke();

        EnemyAI ai = GetComponent<EnemyAI>();
        if (ai != null)
            ai.OnHitAlert(transform.position);

        if (currentHealth <= 0)
        {
            Die();
        }
    }

    void Die()
    {
        isDead = true;
        OnDeath?.Invoke();

        Debug.Log($"{gameObject.name} 被击毙");

        Collider col = GetComponent<Collider>();
        if (col != null) col.enabled = false;

        EnemyAI ai = GetComponent<EnemyAI>();
        if (ai != null) ai.enabled = false;

        Destroy(gameObject, 5f);
    }
}
