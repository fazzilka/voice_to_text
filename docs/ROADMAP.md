# Roadmap

Roadmap отражает порядок снижения рисков, а не обещанные даты.

## 0.1 — macOS beta foundation

- [x] импорт проверенной upstream-базы с историей и MIT-атрибуцией;
- [x] собственные имя, bundle ID, LaunchAgent и каталоги;
- [x] сохранение исходного нативного macOS UI;
- [x] лимит записи 40 минут и recovery headroom;
- [x] portable `VoiceToTextCore` и Linux CI;
- [x] документация и GitFlow;
- [ ] полный ручной microphone/paste smoke test;
- [ ] 40-минутный soak test;
- [ ] первый подписанный release asset и checksum.

## 0.2 — надёжные длинные записи

- [ ] file-backed audio buffer;
- [ ] VAD segmentation и overlapping chunks;
- [ ] инкрементальная сборка транскрипта;
- [ ] progress и отмена долгого ASR;
- [ ] восстановление по завершённым чанкам;
- [ ] benchmark latency/RAM/качества.

## 0.3 — структура и качество

- [ ] разделить macOS `main.swift` на модули;
- [ ] перенести чистую text pipeline в core;
- [ ] добавить fixture-based ASR tests;
- [ ] добавить structured logging без пользовательского текста;
- [ ] accessibility audit и UI regression screenshots;
- [ ] notarized Developer ID build.

## 0.4 — Windows prototype

- [ ] WASAPI capture;
- [ ] ONNX Runtime benchmark;
- [ ] CLI end-to-end prototype;
- [ ] WinUI tray/hotkeys/clipboard;
- [ ] secure storage, autostart и installer.

## 0.5 — Linux prototype

- [ ] PipeWire capture;
- [ ] ONNX Runtime CPU/CUDA;
- [ ] GTK4/Qt shell;
- [ ] X11 и Wayland integration research;
- [ ] AppImage/Flatpak packaging.

## Кандидаты после beta

- streaming partial transcript;
- локальная VAD-индикация и автоматическое завершение по паузе;
- профили словарей по приложениям;
- несколько ASR backends;
- экспорт в Markdown/JSON/SRT;
- opt-in encrypted sync без передачи аудио.
