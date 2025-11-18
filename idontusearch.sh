#!/bin/bash

CONFIG_PATH="$HOME/.config/fastfetch/config.jsonc"

# generating config if it doesn't exist
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Config not found. Generating new one..."
    fastfetch --gen-config
fi

# backing up old config
read -p "Do you want to create a backup of your old config? (y/N): " backup_choice
if [[ $backup_choice =~ [yY] ]]; then
    cp "$CONFIG_PATH" "${CONFIG_PATH}.old"
    echo "Backup created: ${CONFIG_PATH}.old"
fi

# choosing logo
read -p "Choose your logo (arch/arch_small): " logo_choice
case $logo_choice in
    arch|arch_small) ;;
    *) echo "Wrong logo. Using arch as default"; logo_choice="arch" ;;
esac

# updating logo
if grep -q '"logo":' "$CONFIG_PATH"; then
    sed -i "s/\"logo\": *\"[^\"]*\"/\"logo\": \"$logo_choice\"/" "$CONFIG_PATH"
else
    sed -i "1s/{/{\n  \"logo\": \"$logo_choice\",/" "$CONFIG_PATH"
fi

# changing os info
if grep -q '"os",' "$CONFIG_PATH"; then
    # 1: just "os",
    sed -i 's/"os",/{\n      "type": "os",\n      "format": "Arch Linux x86"\n    },/' "$CONFIG_PATH"
elif grep -q '"type": *"os"' "$CONFIG_PATH"; then
    # 2: full module with type "os"
    sed -i '/"type": *"os"/,/}/{s/"format": *"[^"]*"/"format": "Arch Linux x86"/}' "$CONFIG_PATH"
else
    # 3: creating new one because os module wasn't found
    echo "OS module not found, creating new one..."
    if grep -q '"modules": \[' "$CONFIG_PATH"; then
        sed -i '/"modules": \[/a\    {\n      "type": "os",\n      "format": "Arch Linux x86"\n    },' "$CONFIG_PATH"
    else
        echo "Error: No place for OS module was found"
        exit 1
    fi
fi

echo "Done! Now your fastfetch will show that you use Arch btw (you actually don't, hehe)"
