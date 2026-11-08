using UnityEngine;

/// <summary>
/// 武器系统 - 射击、换弹、弹药管理
/// </summary>
public class WeaponSystem : MonoBehaviour
{
    [Header("武器设置")]
    public string weaponName = "汉阳造步枪";
    public float damage = 25f;
    public float fireRate = 1.5f; // 每秒射击次数
    public int magazineSize = 5;
    public float reloadTime = 2.5f;
    public float range = 100f;

    [Header("弹药")]
    public int currentAmmo = 5;
    public int reserveAmmo = 30;

    [Header("引用")]
    public Transform firePoint;
    public GameObject bulletPrefab;
    public Camera playerCamera;
    public ParticleSystem muzzleFlash;

    private float nextFireTime = 0f;
    private bool isReloading = false;

    void Start()
    {
        currentAmmo = magazineSize;
        if (playerCamera == null)
            playerCamera = GetComponentInParent<Camera>();
    }

    void Update()
    {
        if (isReloading) return;

        // 射击
        if (Input.GetButton("Fire1") && Time.time >= nextFireTime)
        {
            Fire();
        }

        // 换弹
        if (Input.GetKeyDown(KeyCode.R) && currentAmmo < magazineSize && reserveAmmo > 0)
        {
            StartCoroutine(Reload());
        }
    }

    void Fire()
    {
        nextFireTime = Time.time + 1f / fireRate;

        if (currentAmmo <= 0)
        {
            Debug.Log("弹药耗尽，按R换弹");
            return;
        }

        currentAmmo--;

        // 枪口火光
        if (muzzleFlash != null)
            muzzleFlash.Play();

        // 射线检测
        RaycastHit hit;
        if (Physics.Raycast(playerCamera.transform.position, playerCamera.transform.forward, out hit, range))
        {
            Debug.Log($"命中: {hit.collider.name}");

            // 伤害检测
            EnemyHealth enemyHealth = hit.collider.GetComponent<EnemyHealth>();
            if (enemyHealth != null)
            {
                enemyHealth.TakeDamage(damage);
            }

            // 生成弹丸预制体（可选）
            if (bulletPrefab != null && firePoint != null)
            {
                Instantiate(bulletPrefab, firePoint.position, firePoint.rotation);
            }
        }
    }

    System.Collections.IEnumerator Reload()
    {
        isReloading = true;
        Debug.Log("开始换弹...");

        yield return new WaitForSeconds(reloadTime);

        int need = magazineSize - currentAmmo;
        int take = Mathf.Min(need, reserveAmmo);
        currentAmmo += take;
        reserveAmmo -= take;

        isReloading = false;
        Debug.Log("换弹完成");
    }

    public int GetCurrentAmmo() => currentAmmo;
    public int GetReserveAmmo() => reserveAmmo;
    public bool IsReloading() => isReloading;
}
