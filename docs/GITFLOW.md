# GitFlow проекта

Схема повторяет практику
[`fazzilka/deploy_pp_time_traking`](https://github.com/fazzilka/deploy_pp_time_traking):
стабильная `main`, ветки по типу работы и merge через Pull Request. Постоянная
ветка `develop` не используется.

## Ветки

| Тип | Шаблон | Пример |
|---|---|---|
| Функция | `feature/<ID>-<slug>` | `feature/VTT-002-chunked-asr` |
| Исправление | `fix/<ID>-<slug>` | `fix/VTT-003-audio-restart` |
| Безопасность | `security/<ID>-<slug>` | `security/VTT-004-update-validation` |
| Зависимости | `dependabot/...` | создаёт Dependabot |

`main` всегда должна собираться. Прямые продуктовые коммиты в `main` после
bootstrap не делаются.

## Рабочий цикл

```bash
git switch main
git pull --ff-only origin main
git switch -c feature/VTT-002-short-description
```

Во время работы коммиты должны быть небольшими и осмысленными:

```text
feat(audio): add chunk boundary policy
fix(agent): recover input after sleep
test(core): cover overlapping transcript merge
docs(platforms): record Windows adapter decision
```

Перед push:

```bash
./scripts/check.sh
swift run --package-path core VoiceToTextCoreChecks
swift run -c debug --package-path swift VoiceToText --self-test all
./scripts/build-app.sh ./dist/VoiceToText.app
git diff --check
git status --short
```

Затем ветка публикуется и открывается draft PR:

```bash
git push -u origin feature/VTT-002-short-description
```

## Pull Request

Описание PR включает:

- задачу и пользовательский результат;
- ключевые технические решения;
- риски и обратную совместимость;
- выполненные автоматические тесты;
- ручные проверки macOS;
- скриншоты только если менялся UI;
- влияние на приватность, разрешения и данные.

Merge разрешается после зелёного CI и review. Для feature/fix используется
обычный merge commit, как в эталонном репозитории, чтобы история PR оставалась
видимой. Ветка после merge удаляется на сервере.

## Releases

Release готовится отдельным PR: версия, changelog, pinned checksum и smoke
workflow меняются вместе. Tag `vX.Y.Z` ставится на merge commit в `main`.
Опубликованные архивы не заменяются: исправление получает новую версию.

## Upstream

Изменения SuperDictate рассматриваются как внешний upstream. Для каждого
обновления создаётся отдельная ветка, фиксируется диапазон изученных коммитов,
а перенос выполняется cherry-pick или ручной адаптацией с сохранением
атрибуции. Merge всего upstream/main без review не допускается.
