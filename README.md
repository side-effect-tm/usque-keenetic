# usque-keenetic

[![GitHub Release](https://img.shields.io/github/release/side-effect-tm/usque-keenetic?style=flat&color=green)](https://side-effect-tm.github.io/usque-keenetic/releases)
[![License](https://img.shields.io/github/license/side-effect-tm/usque-keenetic.svg?style=flat&color=orange)](LICENSE)

Адаптация [неофициального Cloudflare WARP клиента с режимом MASQUE](https://github.com/Diniboy1123/usque) для роутеров for Keenetic/Netcaze.

> [!WARNING]
> Пакет создан в исследовательских целях и предоставляется по схеме "AS IS".
> Вы можете использовать его на своем оборудовании при условии, что понимаете
> смысл своих действий, осознаете риски и принимаете их.

## ⚡ Тебования

* Keenetic OS >= 5.0 (предполагается использование встроенной DNS-маршрутизации)
* Entware
* Доступ к подсетям Cloudflare (вероятно потребуется nfqws, nfqws2, или другие инструменты)

## 🛠 Подготовка

1. Установите Entware по инструкции к вашему роутеру.
Рекомендуется установка [на внешний USB-накопитель](https://help.keenetic.com/hc/ru/articles/360021214160),
но также возможна установка и [на встроенную память роутера](https://help.keenetic.com/hc/ru/articles/360021888880).

2. Убедитесь, что у вас есть доступ к Entware.

    Для подключения используйте ssh (рекомендуется) согласно упомянутой выше инструкции к вашему роутеру.
    Обычно используется порт 22, а роутер имеет ip адрес 192.168.1.1:

    ```sh
    ssh root@192.168.1.1
    ```

    либо порт 222, если 22 уже занят

    ```sh
    ssh root@192.168.1.1 -p 222
    ```

    Также можно воспользоваться устаревшим способом подключения через telnet

    ```sh
    telnet 192.168.1.1
    exec sh
    ```

    > [!IMPORTANT]
    > Важно чтобы вы получили сессию именно в Entware, а не во внутреннем CLI устройства.

## 📦 Установка

1. Подключитесь к Entware.
2. Зарегистрируйте новый opkg-репозиторий

    ```sh
    mkdir -p /opt/etc/opkg
    echo "src/gz usque-keenetic https://side-effect-tm.github.io/usque-keenetic/all" > /opt/etc/opkg/usque-keenetic.conf
    ```

    Репозиторий универсальный. Поддерживаемые архитектуры: `aarch64`, `mipsel`, `mips`.

    <details>
      <summary>Или можете выбрать репозиторий под конкретную архитектуру</summary>

      - `aarch64-3.10`
        ```bash
        mkdir -p /opt/etc/opkg
        echo "src/gz usque-keenetic https://side-effect-tm.github.io/usque-keenetic/aarch64" > /opt/etc/opkg/usque-keenetic.conf
        ```

      - `mipsel-3.4`
        ```bash
        mkdir -p /opt/etc/opkg
        echo "src/gz usque-keenetic https://side-effect-tm.github.io/usque-keenetic/mipsel" > /opt/etc/opkg/usque-keenetic.conf
        ```

      - `mips-3.4`
        ```sh
        mkdir -p /opt/etc/opkg
        echo "src/gz usque-keenetic https://side-effect-tm.github.io/usque-keenetic/mips" > /opt/etc/opkg/usque-keenetic.conf
        ```
    
    </details>

3. Установите пакет

    ```sh
    opkg update
    opkg install usque-keenetic
    ```

## ↻ Обновление

1. Подключитесь к Entware.
2. Обновите пакет

    ```sh
    opkg update
    opkg upgrade usque-keenetic
    ```

    Или обновите сразу все пакеты

    ```sh
    opkg update
    opkg upgrade
    ```

## 🗑️ Удаление

1. Подключитесь к Entware.
2. Удалите пакет

    ```sh
    opkg remove --autoremove usque-keenetic
    ```

## ⚙ Конфигурация

Файл конфигурации расположен по пути `/opt/etc/usque/usque.conf`

```sh
# Интерфейс. Определяется автоматически при установке.
# Должен быть вида opkgtun*
IFACE="opkgtun0"

# IP адрес (опционально).
# По умолчанию адрес выбирается автоматически при запуске сервиса
# в диапазоне 172.16.1.100 - 172.16.1.200.
# IFACE_IP="172.16.0.1"

# Маска подсети (опционально).
# По умолчанию - 255.255.255.255
# IFACE_MASK="255.255.255.255"

# SNI для маскировки трафика
SNI="ozon.ru"

# Версия конфигурации
# !!! Не изменяйте это значение вручную !!!
CONFIG_VERSION=1
```

## Благодарности

Этот проект существует благодаря другим, перечисленным ниже:

1. [Diniboy1123/usque](https://github.com/Diniboy1123/usque) - Спасибо за реализацию Cloudflare WARP client's MASQUE mode и готовые бинарники под aarch64, mips, mipsel;
2. [nfqws/nfqws2-keenetic](https://github.com/nfqws/nfqws2-keenetic) - Спасибо за иллюстрацию сборки ipk пакетов, организацию opkg репозитория, а также некоторые скрипты.
