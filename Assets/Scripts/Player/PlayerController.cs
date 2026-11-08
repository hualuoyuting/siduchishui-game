using UnityEngine;

/// <summary>
/// 第一人称玩家控制器
/// 操作: WASD移动, 鼠标视角, Shift奔跑, 空格跳跃
/// </summary>
[RequireComponent(typeof(CharacterController))]
public class PlayerController : MonoBehaviour
{
    [Header("移动设置")]
    public float walkSpeed = 4f;
    public float runSpeed = 7f;
    public float jumpHeight = 1.5f;
    public float gravity = -9.81f;
    public float mouseSensitivity = 2f;

    [Header("引用")]
    public Camera playerCamera;
    public PlayerStamina stamina;

    private CharacterController controller;
    private Vector3 velocity;
    private float xRotation = 0f;
    private bool isRunning = false;

    void Start()
    {
        controller = GetComponent<CharacterController>();
        if (playerCamera == null)
            playerCamera = GetComponentInChildren<Camera>();
        if (stamina == null)
            stamina = GetComponent<PlayerStamina>();

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    void Update()
    {
        HandleMouseLook();
        HandleMovement();
    }

    void HandleMouseLook()
    {
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity;
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity;

        xRotation -= mouseY;
        xRotation = Mathf.Clamp(xRotation, -90f, 90f);

        playerCamera.transform.localRotation = Quaternion.Euler(xRotation, 0f, 0f);
        transform.Rotate(Vector3.up * mouseX);
    }

    void HandleMovement()
    {
        // 地面检查
        if (controller.isGrounded && velocity.y < 0)
        {
            velocity.y = -2f;
        }

        // 移动输入
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        // 奔跑判断
        isRunning = Input.GetKey(KeyCode.LeftShift) && vertical > 0;

        // 体力消耗
        if (isRunning && stamina != null)
        {
            if (!stamina.Consume(Time.deltaTime * 15f))
                isRunning = false; // 体力不足，停止奔跑
        }

        float speed = isRunning ? runSpeed : walkSpeed;

        Vector3 move = transform.right * horizontal + transform.forward * vertical;
        controller.Move(move.normalized * speed * Time.deltaTime);

        // 跳跃
        if (Input.GetButtonDown("Jump") && controller.isGrounded)
        {
            velocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);
        }

        // 重力
        velocity.y += gravity * Time.deltaTime;
        controller.Move(velocity * Time.deltaTime);
    }

    public bool IsRunning() => isRunning;
}
