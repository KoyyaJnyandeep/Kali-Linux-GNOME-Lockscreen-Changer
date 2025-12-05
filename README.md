🔐 Kali Linux GNOME Lockscreen Changer

A lightweight script to change the GNOME lockscreen wallpaper on Kali Linux.

📌 Overview

By default, GNOME stores its lockscreen wallpaper inside protected system directories, making manual customization difficult.
This project provides a simple, safe, and automated script that lets you replace the Kali GNOME lockscreen background with any image of your choice using just one command.

It also creates a backup of your original lockscreen file so you can restore it at any time.

🚀 Features

✔️ Change GNOME lockscreen wallpaper instantly

✔️ Automatic backup & restore support

✔️ Supports JPG, PNG, JPEG

✔️ Validates user input

✔️ Safe system file handling with permission checks

✔️ Works on Kali Linux GNOME Desktop

📂 Project Structure
kali-gnome-lockscreen-changer/
│── lckscrnchngr.sh       # Main script
│── README.md             # Documentation
└── assets/               # (optional) Example wallpapers / screenshots

🔧 Installation

Clone the repository and enter the directory:

git clone https://github.com/<your-username>/kali-gnome-lockscreen-changer.git
cd kali-gnome-lockscreen-changer


Make the script executable:

chmod +x lckscrnchngr.sh

🖼 Usage

To change the lockscreen wallpaper:

sudo ./lckscrnchngr.sh /path/to/your/wallpaper.jpg

Example:
sudo ./lckscrnchngr.sh ~/Pictures/hacker_theme.png

🔄 Restoring Original Wallpaper

If you want to revert back to the original lockscreen:

sudo cp /usr/share/gnome-shell/theme/wallpaper.locked.bak /usr/share/gnome-shell/theme/noise-texture.png


(The script automatically creates the backup.)

⚙️ How It Works (Internals)

The script performs the following steps:

Validates input image & path

Detects GNOME lockscreen texture file (commonly noise-texture.png)

Creates a backup (wallpaper.locked.bak)

Replaces the texture with your custom wallpaper

Fixes ownership and permission issues

Reloads GNOME theme (optional)

This ensures maximum safety and reversibility.

🛡 Requirements

Kali Linux

GNOME Desktop Environment

sudo privileges

Supported image format: PNG, JPG, JPEG

⚠️ Disclaimer

This script edits system theme files.
It is safe when used correctly, but improper modification may affect your GNOME shell theme.
Use at your own risk.

🤝 Contributing

Pull requests are welcome! If you want to improve:

Code optimization

Add cron-based auto-rotation

Add random wallpaper selector

Add GUI frontend

Feel free to contribute.

⭐ Support

If you find this project useful, please consider giving it a ⭐ on GitHub.
It helps grow the project and motivates further development.
