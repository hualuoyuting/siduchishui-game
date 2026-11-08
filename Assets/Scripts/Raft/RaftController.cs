using UnityEngine;

/// <summary>
/// 竹筏渡河控制器
/// 玩家按E登筏，竹筏自动顺流而下
/// </summary>
public class RaftController : MonoBehaviour
{
    [Header("渡河设置")]
    public float riverSpeed = 3f;
    public float crossingDistance = 200f;
    public Vector3 startPosition;
    public Vector3 endPosition;

    [Header("引用")]
    public Transform raftSeat;
    public bool isCrossing = false;
    public bool isBoarded = false;

    private PlayerController player;
    private Vector3 riverDirection;

    void Start()
    {
        startPosition = transform.position;
        if (endPosition == Vector3.zero)
            endPosition = startPosition + Vector3.forward * crossingDistance;
        riverDirection = (endPosition - startPosition).normalized;
    }

    void Update()
    {
        if (!isBoarded && player != null)
        {
            float dist = Vector3.Distance(player.transform.position, transform.position);
            if (dist < 3f && Input.GetKeyDown(KeyCode.E))
            {
                BoardRaft();
            }
        }

        if (isCrossing && isBoarded)
        {
            transform.Translate(riverDirection * riverSpeed * Time.deltaTime);

            if (Vector3.Distance(transform.position, endPosition) < 5f)
            {
                ArriveBank();
            }
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            player = other.GetComponent<PlayerController>();
            Debug.Log("靠近竹筏，按E登筏");
        }
    }

    void BoardRaft()
    {
        isBoarded = true;
        isCrossing = true;

        if (player != null && raftSeat != null)
        {
            player.transform.SetParent(transform);
            player.transform.position = raftSeat.position;
            player.enabled = false;
            Debug.Log("登上竹筏，开始渡河！");
        }
    }

    void ArriveBank()
    {
        isCrossing = false;

        if (player != null)
        {
            player.transform.SetParent(null);
            player.enabled = true;

            MissionManager mission = MissionManager.Instance;
            if (mission != null)
            {
                Objective current = mission.GetCurrentObjective();
                if (current != null && current.type == ObjectiveType.Interact)
                {
                    current.CompleteInteract();
                }
            }

            Debug.Log("成功渡河！");
        }
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.cyan;
        Gizmos.DrawLine(startPosition, endPosition);
        Gizmos.DrawWireSphere(startPosition, 3f);
        Gizmos.DrawWireSphere(endPosition, 3f);
    }
}
