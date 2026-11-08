using UnityEngine;
using System.Collections.Generic;
using UnityEngine.Events;

/// <summary>
/// 任务管理器 - 管理当前章节的所有目标
/// </summary>
public class MissionManager : MonoBehaviour
{
    public static MissionManager Instance { get; private set; }

    [Header("任务信息")]
    public string chapterTitle = "第一章：土城突围";
    public string chapterDate = "1935年1月29日";

    [Header("事件")]
    public UnityEvent OnMissionComplete;
    public UnityEvent OnObjectiveComplete;

    public List<Objective> objectives = new List<Objective>();
    private int currentObjectiveIndex = 0;
    public bool isMissionComplete = false;

    void Awake()
    {
        Instance = this;
    }

    void Start()
    {
        foreach (var obj in objectives)
        {
            obj.isCompleted = false;
        }

        if (objectives.Count > 0)
        {
            objectives[0].isActive = true;
            Debug.Log($"当前目标: {objectives[0].description}");
        }
    }

    void Update()
    {
        if (isMissionComplete) return;

        if (currentObjectiveIndex < objectives.Count)
        {
            Objective current = objectives[currentObjectiveIndex];
            if (current.isActive && current.CheckComplete())
            {
                CompleteObjective(current);
            }
        }
    }

    void CompleteObjective(Objective obj)
    {
        obj.isCompleted = true;
        obj.isActive = false;
        OnObjectiveComplete?.Invoke();

        Debug.Log($"目标完成: {obj.description}");

        currentObjectiveIndex++;

        if (currentObjectiveIndex < objectives.Count)
        {
            objectives[currentObjectiveIndex].isActive = true;
            Debug.Log($"新目标: {objectives[currentObjectiveIndex].description}");
        }
        else
        {
            isMissionComplete = true;
            OnMissionComplete?.Invoke();
            Debug.Log("章节任务全部完成！");
        }
    }

    public Objective GetCurrentObjective()
    {
        if (currentObjectiveIndex < objectives.Count)
            return objectives[currentObjectiveIndex];
        return null;
    }

    public List<Objective> GetAllObjectives() => objectives;
}

/// <summary>
/// 目标类型枚举
/// </summary>
public enum ObjectiveType
{
    Reach,      // 到达指定位置
    Kill,       // 击杀指定数量敌人
    Defend,     // 防守某个点
    Interact,   // 交互（登船/使用物品）
    Survive     // 存活指定时间
}
