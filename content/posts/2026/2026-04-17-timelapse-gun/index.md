---
title: "Action = Reaction, the third law of Newton as a game mechanic !?"
date: 2026-04-17
series: ["timelapse"]
episode: 3
tags: ["unity", "c#", "game"]
---
I made a few abilities for my platformer game made using Unity.
the goal was for each ability to represent a period of time, be it the past, the present or the future.

## The Gun

{{< video src="timelapse-gun.mp4" >}}
This ability is the one supposed to represent the present days, of course I had to take the most famous weapon of our current days, the gun.  
That and the idea of a character shooting with a gun to propel himself the other way seemed really interesting and funny to us.  

## How does it work ?  

### 1. the gun

```csharp
private void Update(){
    Vector2 mousePos = Mouse.current.position.ReadValue();
    Vector2 worldPoint = mainCamera.ScreenToWorldPoint(mousePos);
    Vector2 direction = worldPoint - (Vector2)transform.position;
    float angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;
    weapon.rotation = Quaternion.Euler(0, 0, angle);
    weapon.position = transform.position + (Vector3)(direction.normalized * gunDistance);
    if (weaponObject.transform.localPosition.x < 0)
    {
        weaponSpriteRenderer.flipY = true;
    } else {
        weaponSpriteRenderer.flipY = false;
    }
    if (InputActions.Player.Shoot.triggered && shots < ammoCapacity){
        ShootGun();
        shots += 1;
    }
    if (playerMovement.GetIsGrounded()){
        Reload();
    }
}
```

The gun works like so, if the player is in the air, he gets two shots, if not, he can shoot as much as he wants. To do so, whenever the player shoots, it increases the amount of the variable "shots" by one. If the player is grounded, it automatically reloads his gun, which resets this variable back to 0.  
when the player shoots, it also calls in the following function.  
```csharp
private void ShootGun(){
    SoundManager.Instance.PlaySound2D("gun");
    ammo = Instantiate(ammoPrefab, weapon.position, weapon.rotation);
    Rigidbody2D ammorb = ammo.GetComponent<Rigidbody2D>();
    ammorb.linearVelocity = weapon.right * bulletSpeed;
    rb.linearVelocity = Vector2.zero;
    recoilDirection = -new Vector2(weapon.position.x - transform.position.x, (weapon.position.y - transform.position.y)* 1.2f);
    rb.AddForce(recoilDirection * recoilForce, ForceMode2D.Impulse);
}
```
Basically, it creates a new gameobject using a prefab, you can think of it like a blue print.
it creates it and then immediately changes its linear velocity to launch it flying. in return, it applies a force on the player to mimic the recoil of the gun.  
Unlike in this third law of Newton, the force that propels the bullet and the one launching the player aren't the same, in this case I chose to sacrifice realisme for better game design because if it did, the player would barely move at all and there would be no point in this ability at all.  

### 2. the ammo

```csharp
void Start()
{
    Destroy(gameObject, 1.0f);
}

void OnTriggerEnter2D(Collider2D collision)
{
    if (collision.gameObject.layer == LayerMask.NameToLayer("Ground"))
    {
        Destroy(gameObject);
    }
}
```
The script of the ammo is probably the shortest one in the whole game.  
When the ammo is created, it calls in the function Destroy after 1 second to make sure it disapears if it doesn't hit anything before.  
Whenever its trigger detects an item, it destroys it if the item is on the ground layer but does nothing otherwise, allowing the player to shoot multiple enemies in a single shot if they are alligned properly.