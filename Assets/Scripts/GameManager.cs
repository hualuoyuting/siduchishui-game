using UnityEngine;

/// <summary>
/// 游戏总管理器 - 全局单例
/// </summary>
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    [Header("全局设置")]
    public int currentChapter = 1;
    public bool isGamePaused = false;
    public float gameTime = 0f;

    public event System.Action OnGamePause;
    public event System.Action OnGameResume;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    void Update()
    {
        if (!isGamePaused)
        {
            gameTime += Time.deltaTime;
        }
    }

    public void PauseGame()
    {
        isGamePaused = true;
        Time.timeScale = 0f;
        OnGamePause?.Invoke();
    }

    public void ResumeGame()
    {
        isGamePaused = false;
        Time.timeScale = 1f;
        OnGameResume?.Invoke();
    }

    public void LoadChapter(int chapter)
    {
        currentChapter = chapter;
        UnityEngine.SceneManagement.SceneManager.LoadScene($"Chapter{chapter}");
    }

    public void QuitGame()
    {
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif
    }
}
