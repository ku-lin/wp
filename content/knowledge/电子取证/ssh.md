---
title: "ssh"
draft: false
---
### 在 Linux 上启用 SSH 服务

1. **安装 SSH 服务**  
    大多数 Linux 发行版（如 Ubuntu 或 CentOS）默认安装了 OpenSSH。如果没有安装，可以通过以下命令安装：
    - **Ubuntu/Debian**:
        
        sudo apt update  
        sudo apt install openssh-server
        
    - **CentOS/RHEL**:
        
        sudo yum install openssh-server
        
2. **启动 SSH 服务**  
    安装完成后，你需要启动 SSH 服务并使其随系统启动：
    
    sudo systemctl start ssh  
    sudo systemctl enable ssh
    
3. **检查 SSH 服务状态**  
    可以使用以下命令检查 SSH 服务是否已正确启动：
    
    sudo systemctl status ssh
    
4. **开放防火墙端口（如果需要）**  
    如果你的系统启用了防火墙，确保开放 22 端口（默认的 SSH 端口）：
    - **使用 UFW（适用于 Ubuntu/Debian）**:
        
        sudo ufw allow ssh
        
    - **使用 firewall-cmd（适用于 CentOS/RHEL）**:
        
        sudo firewall-cmd --permanent --add-service=ssh  
        sudo firewall-cmd --reload
