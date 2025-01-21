# Changelog

## 1.2.0 (21.01.2025)
- [Remove website availability use case](https://github.com/kommitters/bas_use_cases/pull/58)

## 1.1.1 (09.01.2025)
- [Remove unnecessary env variables](https://github.com/kommitters/bas_use_cases/pull/56)

## 1.1.0 (09.01.2025)
- [Use cases migration](https://github.com/kommitters/bas_use_cases/pull/46)
- [Wpp interface](https://github.com/kommitters/bas_use_cases/pull/47)
- [Avoid unprocessable messages and improve bot message response](https://github.com/kommitters/bas_use_cases/pull/49)
- [Programmed executor](https://github.com/kommitters/bas_use_cases/pull/51)
- [Add save backup in s3 implementation](https://github.com/kommitters/bas_use_cases/pulls?q=is%3Apr+is%3Aclosed)
- [Update bas gem to version 1.6.2](https://github.com/kommitters/bas_use_cases/pull/53)
- [Remove bas_db container](https://github.com/kommitters/bas_use_cases/pull/54)

## 1.0.2 (05.11.2024)
- Integrate conversational bots private gem

## 1.0.1 (28.10.2024)
- Remove sidekiq configuration given production memory errors
- Update bas version to 1.5.3

## 1.0.0 (23.10.2024)
- Remove logic to execute use cases bots with cronjobs
- Add the sidekiq gem to manage the execution schedules
- Add a redis container to manage the sidekiq execution queue.

## 0.6.0 (09.10.2024)
- Add dicord bot to manage image review requests
- Update telegram bot to manage list_websites and remove_websites commands

## 0.5.0 (30.09.2024)
- Add telegram bot service to process web availability

## 0.4.2 (12.09.2024)
- Hotfix database config

## 0.4.1 (12.09.2024)
- Fix pem file reading error

## 0.4.0 (12.09.2024)
- Add ChaincertsDapp to the OPSO maintenance projects

## 0.3.2 (06.09.2024)
- Update bas gem version to 1.4.3

## 0.3.1 (30.08.2024)
- Update bas gem version to 1.4.2

## 0.3.0 (19.07.2024)
- Add websites availability use case

## 0.2.1 (16.07.2024)
- Update environment variables config

## 0.2.0 (16.07.2024)
- Add digital ocean bill alert use case

## 0.1.2 (09.07.2024)
- Update bas gem version to 1.1.3

## 0.1.1 (03.07.2024)
- Update review media schedules

## 0.1.0 (03.07.2024)
- Add review images use case
- Add review text use case

## 0.0.2 (26.06.2024)
- Update schedules and BAS version to 1.0.1

## 0.0.1 (18.06.2024)
- Add script and cronjobs base architecture
- Add docker compose services config
- Implement notification birthday use case
- Implement notification next week birthday use case
- Implement notification pto use case
- Implement notification pto next week use case
- Implement support email notification use case
- Implement notification wip limit use case
