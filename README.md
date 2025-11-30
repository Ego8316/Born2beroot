<p align="center">
  <img src="https://raw.githubusercontent.com/ayogun/42-project-badges/main/badges/Born2berootm.png" height="150" alt="42 get_next_line Badge"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/42-Project-blue" height="32"/>
  <img src="https://img.shields.io/github/languages/code-size/Ego8316/get_next_line?color=5BCFFF" height="32"/>
</p>

# Born2beroot

Hardening cheatsheet for 42's Born2beroot project. The subject is about system administration, not coding, so this repo just collects the steps, configs, and helper scripts needed to deploy a minimal Debian server, lock it down, and keep it reproducible for evaluation.

## 📦 What’s in this repo
- `monitoring.sh` — system summary sent with `wall` (CPU, RAM, disk, network, sudo count).
- `renamevg.sh` — renames the LVM volume group to `LVMGroup` and rewrites boot/fstab entries if you used another name.
- `signature.txt` — hash used by Moulinette.
- `notes.pdf` — personal notes taken while setting up the VM.
- `cheatsheet.pdf` — condensed cheatsheet with commands useful during evaluation.

## 🖥️ VM build (Debian)
- Create a UEFI VM with 2 vCPUs, 2–4 GB RAM, 30 GB disk; attach the Debian netinst ISO.
- Partitioning: one small `/boot` (non-LVM) + the rest as an LVM PV. Inside the VG create at least `root` and `swap` logical volumes. You can rename the VG later with `renamevg.sh`.
- Set the hostname to `login42` and create the user `<login>` matching your 42 intra login. Give it its own password (different from root).

## 🛠️ Mandatory configuration
- Groups: add your user to `sudo` and `user42` (`sudo adduser <login> sudo` and `sudo adduser <login> user42`).
- Hostname: `/etc/hostname` contains `login42`; `/etc/hosts` maps `127.0.1.1 login42`.
- Timezone: set with `sudo dpkg-reconfigure tzdata` or `timedatectl set-timezone <Zone/City>`.

### 🔐 Password policy
- `/etc/login.defs`:  
  `PASS_MAX_DAYS 30`, `PASS_MIN_DAYS 2`, `PASS_WARN_AGE 7`.
- `/etc/pam.d/common-password` (libpam-pwquality):  
  `password requisite pam_pwquality.so retry=3 minlen=10 ucredit=-1 lcredit=-1 dcredit=-1 maxrepeat=3 reject_username difok=7 enforce_for_root`.
- Apply the policy to existing accounts: `sudo chage --maxdays 30 --mindays 2 --warndays 7 <user>`.

### 🧰 Sudo hardening
Create `/etc/sudoers.d/42` (via `sudo visudo -f /etc/sudoers.d/42`):
```
Defaults    passwd_tries=3
Defaults    badpass_message="Wrong password"
Defaults    logfile="/var/log/sudo/sudo.log"
Defaults    log_input,log_output
Defaults    iolog_dir="/var/log/sudo"
Defaults    requiretty
Defaults    secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
%sudo ALL=(ALL:ALL) ALL
```

### 🛰️ SSH + Firewall
- Install OpenSSH server: `sudo apt install openssh-server`.
- `/etc/ssh/sshd_config`: set `Port 4242`, `PermitRootLogin no`, and disable password login for root (already covered by the previous option).
- Restart: `sudo systemctl restart ssh`.
- Enable firewall with only port 4242 open: `sudo ufw allow 4242/tcp && sudo ufw enable`.

### 📊 Monitoring script
- Place `monitoring.sh` in `/usr/local/bin` and make it executable (`chmod +x`).
- Cron (root): `*/10 * * * * /usr/local/bin/monitoring.sh`.
- The script prints architecture, CPU/RAM/disk usage, boot time, LVM status, connections, logged users, network info, and sudo command count.

### 🧩 Fixing the VG name
Use this if, like me, you installed with the wrong VG name and need to match the project’s expected `LVMGroup`:
```bash
sudo bash renamevg.sh
```
It updates `/etc/fstab`, `/boot/grub/grub.cfg`, renames the VG, then refreshes initramfs.

## ✅ Quick evaluation checklist
- `lsblk`, `ls -l /dev/mapper` show `LVMGroup-root` and `LVMGroup-swap`.
- `sudo ufw status` shows 4242/tcp allowed; `ss -tlnp | grep 4242` confirms SSH on the correct port.
- `sudo visudo -c -f /etc/sudoers.d/42` passes.
- `sudo tail -n 5 /var/log/sudo/sudo.log` records sudo use.
- `sudo systemctl status cron` is active; `grep monitoring /etc/crontab` shows the entry.
- `sudo cat /etc/login.defs` and `grep pam_pwquality /etc/pam.d/common-password` reflect the policy.
- Root login via SSH is refused; user login works with your account only.

## 📄 License
MIT — see `LICENSE`.
