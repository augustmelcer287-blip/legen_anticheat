# 🚨 Legen AntiCheat V1

Legen AntiCheat V1 is a lightweight, optimized FiveM anticheat designed for performance and control.  
Built with stability in mind — no event overflow, no spam, and clean admin tools.

---

## 🔥 Features

- 🛡️ Godmode & health detection (optimized)
- ⚡ No network event overflow
- 🔁 Stable heartbeat system
- 🔫 Blacklisted weapons protection
- 💥 Explosion protection
- 🚫 Event spam protection
- 👮 Admin menu (`/ssm`)
- 🔨 Ban / Kick / Unban system
- 📜 Discord logging support
- 🔓 ACE permission system (admin + bypass)

---

## 📦 Installation

1. Drag the resource into your server:


2. Add to your `server.cfg`:
```cfg
ensure legen_anticheat_v1

# Admin Permissions
add_ace group.owner legenac.admin allow
add_ace group.owner legenac.bypass allow

add_ace group.admin legenac.bypass allow
add_ace group.mod legenac.bypass allow

# Add your staff
add_principal identifier.fivem:7900167 group.owner
add_principal identifier.fivem:15394988 group.owner
add_principal identifier.fivem:16281078 group.admin
