using UnityEngine;
using UnityEngine.Events;

/// <summary>
/// 玩家生命系统
/// </summary>
public class PlayerHealth : MonoBehaviour
{
    [Header("生命设置")]
    public float maxHealth = 100f;
    public float currentHealth;
    public float healPerSecond = 0f; // 自动回复速度，0为关闭

    [Header("事件")]
    public UnityEvent OnDamaged;
    public UnityEvent OnHealed;
    public UnityEvent OnDeath;

    public bool isDead = false;

    void Start()
    {
        currentHealth = maxHealth;
    }

    void Update()
    {
        // 缓慢自动回复（可选）
        if (healPerSecond > 0 && !isDead && currentHealth < maxHealth)
        {
            currentHealth = Mathf.Min(maxHealth, currentHealth + healPerSecond * Time.deltaTime);
            OnHealed?.Invoke();
        }
    }

    public void TakeDamage(float damage)
    {
        if (isDead) return;

        currentHealth -= damage;
        OnDamaged?.Invoke();

        if (currentHealth <= 0)
        {
            currentHealth = 0;
            Die();
        }
    }

    public void Heal(float amount)
    {
        if (isDead) return;
        currentHealth = Mathf.Min(maxHealth, currentHealth + amount);
        OnHealed?.Invoke();
    }

    void Die()
    {
        isDead = true;
        OnDeath?.Invoke();
        Debug.Log("玩家阵亡");

        // 暂停游戏，显示失败界面
        if (GameManager.Instance != null)
            GameManager.Instance.PauseGame();
    }

    public float GetHealthPercent() => currentHealth / maxHealth;
}
