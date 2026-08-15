# Security audit

Дата проверки: 14 августа 2026 года.

## Вывод

В изученной кодовой базе и собранном VoiceToText `0.1.0` не обнаружено
признаков вредоносного кода: скрытых executables, загрузки и запуска
непроверенного payload, обфускации, майнера, keylogger, скрытой эксфильтрации,
отключения Gatekeeper или автоматического сброса TCC.

Это результат source review и локальных проверок, а не математическая гарантия
отсутствия любой неизвестной уязвимости. На Mac не установлены ClamAV, YARA,
Semgrep, Trivy или OSV Scanner, поэтому вывод не основан на их сигнатурах.

## Объём проверки

- целостность Git objects/history через `git fsck --full --strict`;
- текущее дерево tracked-файлов, executable bits и типы файлов;
- shell installers, updater helpers и destructive operations;
- процессы, persistence, LaunchAgent и login item;
- все литералы сетевых адресов и места использования `URLSession`;
- AI-cleanup body, API-key storage и redirect policy;
- модельная загрузка FluidAudio и защита от registry injection;
- состав, подпись, entitlements и dynamic libraries собранного `.app`;
- публичная GitHub Advisory Database для Swift-пакета FluidAudio.

## Dependency review

Единственная внешняя Swift-зависимость — FluidAudio:

```text
313feb4bd692780a9a5b5fa9048fdb119486dde8
```

Один и тот же SHA закреплён в `swift/Package.swift`, записан в
`swift/Package.resolved` и совпал с реально собранным checkout. Manifest этой
ревизии не содержит дополнительных packages, binary targets, unsafe flags или
build plugins. На момент проверки GitHub Advisory GraphQL API вернул `0`
записей для package `FluidAudio` в ecosystem `SWIFT`.

FluidAudio скачивает модель с Hugging Face. VoiceToText блокирует
`REGISTRY_URL` и `MODEL_REGISTRY_URL`, чтобы LaunchAgent не мог незаметно
перенаправить загрузку на посторонний registry, а скачанный набор файлов модели
проверяется по закреплённым SHA-256 и типам filesystem nodes.

## Чувствительные возможности

| Возможность | Зачем нужна | Ограничение |
|---|---|---|
| Microphone | записать диктовку | аудио обрабатывается локально |
| Input Monitoring | глобальный hotkey | используется CGEventTap |
| Accessibility | вставить текст | не отправляет содержимое поля в сеть |
| Clipboard | fallback-вставка | прежнее значение восстанавливается |
| LaunchAgent | фоновая работа | фиксированный label и executable path |
| `tccutil reset` | ремонт сломанных разрешений | только явная кнопка + critical confirmation |
| Shell updater | атомарно заменить `.app` | fixed paths, SHA-256, bundle/signature checks, rollback |
| AI endpoint | опциональная чистка текста | выключен по умолчанию, HTTPS, без redirect, BYOK |

Полный перечень сетевых вызовов хранится в
[`docs/privacy/network-calls.json`](privacy/network-calls.json).

## Проверка установленного artifact

Проверенный bundle:

```text
/Applications/VoiceToText.app
bundle id: com.fazzilka.voicetotext
version: 0.1.0
architecture: arm64
executable SHA-256: 76c328bf1d1c2f2a58c5f8b03a05135759f5bd5494089aa9a346157957a22b1a
```

SHA-256 executable совпал с локально собранным `dist/VoiceToText.app`.
`codesign --verify --deep --strict` прошёл; bundle содержит один executable,
Info.plist, icon и два menu-bar PNG. `otool -L` показал только системные Apple
frameworks и Swift runtime libraries.

Gatekeeper отклоняет текущую сборку, потому что она подписана ad-hoc и не
notarized (`TeamIdentifier` отсутствует). Это ограничение доверенной доставки,
а не признак вируса. Перед распространением другим людям нужен Apple Developer
ID, Hardened Runtime, notarization и новый release audit.

## Автоматическая защита следующих изменений

```bash
./scripts/security-audit.sh
```

Скрипт проверяет целостность Git, точный dependency pin, отсутствие tracked
Mach-O/ELF/PE/archives, неожиданных executable-файлов, bidi control characters,
remote pipe-to-shell и команд отключения системной защиты. Он запускается из
общего `scripts/check.sh` и поэтому входит в CI каждого Pull Request.

## Остаточные риски

- 40-минутный soak test и реальный microphone/paste test требуют ручного
  разрешения пользователя и не относятся к malware scan;
- ad-hoc bundle нельзя безопасно распространять как публичный release;
- пользовательский HTTPS endpoint AI-cleanup получает текст, если функцию
  включили вручную;
- будущие обновления FluidAudio или модели должны проходить отдельный review,
  а не автоматическую смену SHA.
