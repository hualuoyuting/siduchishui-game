using UnityEngine;

/// <summary>
/// 任务目标 - 可序列化的目标定义
/// </summary>
[System.Serializable]
public class Objective
{
    public string description = "到达目的地";
    public ObjectiveType type = ObjectiveType.Reach;

    [Header("到达目标")]
    public Transform targetPoint;
    public float reachDistance = 5f;

    [Header("击杀目标")]
    public int requiredKills = 0;
    public int currentKills = 0;

    [Header("交互目标")]
    public string interactTag = "Raft";

    [Header("存活目标")]
    public float surviveTime = 0f;
    private float surviveTimer = 0f;

    [HideInInspector] public bool isCompleted = false;
    [HideInInspector] public bool isActive = false;

    public bool CheckComplete()
    {
        if (isCompleted) return true;

        switch (type)
        {
            case ObjectiveType.Reach:
                return CheckReach();
            case ObjectiveType.Kill:
                return currentKills >= requiredKills;
            case ObjectiveType.Survive:
                return CheckSurvive();
            case ObjectiveType.Interact:
                return isCompleted;
            case ObjectiveType.Defend:
                return CheckSurvive();
        }
        return false;
    }

    bool CheckReach()
    {
        if (targetPoint == null) return false;
        GameObject player = GameObject.FindGameObjectWithTag("Player");
        if (player == null) return false;
        float dist = Vector3.Distance(player.transform.position, targetPoint.position);
        return dist <= reachDistance;
    }

    bool CheckSurvive()
    {
        surviveTimer += Time.deltaTime;
        return surviveTimer >= surviveTime;
    }

    public void AddKill()
    {
        currentKills++;
    }

    public void CompleteInteract()
    {
        isCompleted = true;
    }

    public float GetProgress()
    {
        switch (type)
        {
            case ObjectiveType.Kill:
                return (float)currentKills / requiredKills;
            case ObjectiveType.Survive:
            case ObjectiveType.Defend:
                return surviveTimer / surviveTime;
            default:
                return isCompleted ? 1f : 0f;
        }
    }
}
