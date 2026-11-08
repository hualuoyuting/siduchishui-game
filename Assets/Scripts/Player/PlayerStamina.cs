using UnityEngine;

/// <summary>
/// 玩家体力系统
/// 奔跑消耗，静止恢复
/// </summary>
public class PlayerStamina : MonoBehaviour
{
    [Header("体力设置")]
    public float maxStamina = 100f;
    public float currentStamina;
    public float runCostPerSecond = 15f;
    public float recoverPerSecond = 20f;
    public float recoverDelay = 1f; // 停止奔跑后多久开始恢复

    private float lastRunTime = -999f;

    void Start()
    {
        currentStamina = maxStamina;
    }

    void Update()
    {
        // 延迟恢复
        if (Time.time - lastRunTime > recoverDelay && currentStamina < maxStamina)
        {
            currentStamina = Mathf.Min(maxStamina, currentStamina + recoverPerSecond * Time.deltaTime);
        }
    }

    /// <summary>
    /// 消耗体力，返回是否足够
    /// </summary>
    public bool Consume(float amount)
    {
        if (currentStamina < amount)
            return false;

        currentStamina -= amount;
        lastRunTime = Time.time;
        return true;
    }

    public float GetStaminaPercent() => currentStamina / maxStamina;
}
