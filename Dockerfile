FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV WINEPREFIX=/opt/wineprefix
ENV WINEARCH=win32
ENV DISPLAY=:0

# 1. Установка Wine и 32‑битной поддержки
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wine32 wine64 xvfb && \
    rm -rf /var/lib/apt/lists/*

# 2. Создаём префикс Wine и ставим необходимые библиотеки (VC++ redist)
RUN xvfb-run wine wineboot --init && \
    xvfb-run wineserver -w

# 3. Копируем MASM из вашего Windows‑образа
COPY --from=ghcr.io/ice-rider/dev_env_masm_x86_container:aa7c95e9df5a5cb4228031d76f74353f17d82abf \
    ["C:\\BuildTools", "/opt/BuildTools"]

# 4. Прописываем PATH для MASM внутри Wine
RUN wine reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" \
    /v PATH /t REG_EXPAND_SZ \
    /d "C:\\windows\\system32;C:\\windows;C:\\BuildTools\\VC\\Tools\\MSVC\\14.40.33807\\bin\\Hostx64\\x86;C:\\BuildTools\\VC\\Tools\\MSVC\\14.40.33807\\bin\\Hostx86\\x86;C:\\BuildTools\\Common7\\IDE" \
    /f

# 5. Алиас для удобного вызова ml.exe
RUN echo '#!/bin/bash\nxvfb-run wine /opt/BuildTools/VC/Tools/MSVC/*/bin/Hostx64/x86/ml.exe "$@"' > /usr/local/bin/ml \
    && chmod +x /usr/local/bin/ml

WORKDIR /workspace
CMD ["/bin/bash"]