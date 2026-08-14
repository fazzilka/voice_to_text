# Тестирование

## Уровни

### 1. Статические проверки

```bash
./scripts/check.sh
```

Проверяются shell syntax, plist, версии/checksum, обязательные entitlements,
защитные условия build/installer и `git diff --check`.

### 2. Portable core

```bash
swift run --package-path core VoiceToTextCoreChecks
```

Текущие тесты подтверждают 40-минутный лимит, запас recovery journal, точный
максимальный размер и вычисление длительности PCM.

### 3. Встроенные self-tests macOS

```bash
swift run -c debug --package-path swift VoiceToText --self-test all
```

Набор проверяет настройки, hotkeys, clipboard/paste, историю, статистику,
коррекции, безопасность путей, целостность модели, update manifest/helper,
pending journal, audio policy, mute recovery, AI cleanup и другие чистые или
изолируемые сценарии.

### 4. Bundle verification

```bash
./scripts/build-app.sh ./dist/VoiceToText.app
test -x ./dist/VoiceToText.app/Contents/MacOS/VoiceToText
codesign --verify --deep --strict ./dist/VoiceToText.app
plutil -lint ./dist/VoiceToText.app/Contents/Info.plist
```

Также проверяются bundle ID, arm64 binary и два microphone entitlements.

### 5. Installer smoke

CI создаёт локальный ZIP, передаёт его URL и checksum через переменные
`VOICE_TO_TEXT_RELEASE_*`, устанавливает bundle в `/Applications`, проверяет
подпись, запускает uninstaller и убеждается, что bundle удалён.

## Ручной smoke test на Mac

После установки в `/Applications`:

1. открыть control panel и проверить отображение beta-версии;
2. выдать три разрешения;
3. дождаться модели и состояния `Работает`;
4. продиктовать 5–10 секунд в TextEdit;
5. проверить русский и английский текст;
6. начать диктовку в одном поле, переключиться в другое приложение до
   завершения и убедиться, что текст вернулся в исходное поле;
7. повторить предыдущий сценарий со свёрнутым исходным окном;
8. закрыть исходное поле во время диктовки и убедиться, что текст сохранился в
   истории, но не попал в текущее активное окно;
9. проверить основной и альтернативный hotkey;
10. проверить историю и повторную вставку;
11. сменить input device;
12. выполнить sleep/wake и повторить диктовку;
13. выключить сеть и убедиться, что локальная диктовка продолжает работать;
14. включить AI cleanup только с тестовым текстом и проверить raw fallback;
15. перезапустить агент из control panel.

## Длинная запись

40 минут нельзя считать проверенными по короткому unit test. Перед публичным
релизом нужен soak test минимум на 41 минуту:

- запись должна автоматически остановиться около 2400 секунд;
- приложение не должно зависнуть или превысить разумный memory budget;
- полученный текст должен сохраниться в истории;
- pending journal должен удалиться после успеха;
- после принудительного завершения процесса journal должен корректно
  восстановиться;
- следующая короткая диктовка должна работать без перезапуска.

Фиксируются модель Mac, версия macOS, пик RAM, время ASR, длительность аудио и
размер recovery файла.

## Что CI не может гарантировать

- качество конкретного микрофона;
- реальные TCC-диалоги и Accessibility insertion;
- поведение всех приложений-получателей;
- позицию HUD в secure/custom text fields;
- фактическое использование ANE;
- качество русского текста на речи пользователя.

Эти пункты входят в ручной release checklist.
