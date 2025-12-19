# Quick Start Guide - Dask Worker Setup

## Prerequisites
- Windows 10/11
- [UV](https://github.com/astral-sh/uv) installed
- [Tailscale](https://tailscale.com/) installed and connected
- Access to Dask scheduler on Tailscale network

## Installation Steps

1. **Clone the repository:**
   ```powershell
   git clone <your-repo-url>
   cd DaskWorker
   ```

2. **Install dependencies:**
   ```powershell
   uv sync
   ```

3. **Configure environment:**
   ```powershell
   Copy-Item .env.example .env
   notepad .env  # Edit with your scheduler IP
   ```

4. **Setup autostart:**
   ```powershell
   .\setup_autostart.ps1
   ```

5. **Test the worker:**
   ```powershell
   .\start_worker.ps1
   ```

## Important Notes

⚠️ **ProtonVPN Conflict**: Disable ProtonVPN before starting the worker. VPNs block Tailscale traffic.

⚠️ **Firewall**: Ensure Windows Firewall allows the worker to communicate through Tailscale.

⚠️ **Tailscale**: Make sure Tailscale is running and connected before starting the worker.

## Verification

Check if worker is connected:
```powershell
Test-NetConnection -ComputerName <SCHEDULER_IP> -Port 8786
```

Check worker process:
```powershell
Get-Process | Where-Object { $_.ProcessName -like "*python*" }
```

View logs:
```powershell
Get-Content worker.log -Tail 20
```

## Troubleshooting

If worker doesn't connect:
1. Disconnect ProtonVPN
2. Restart Tailscale: `tailscale up`
3. Check connectivity: `Test-NetConnection -ComputerName <SCHEDULER_IP> -Port 8786`
4. Review logs: `Get-Content worker.log`
