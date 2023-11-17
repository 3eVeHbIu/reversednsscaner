# reverse dns scanner bash/powershell scripts
### Usage
#### bash
![2023-11-18_00-57](https://github.com/sergo2048/reversednsscaner/assets/40056618/b71b9aa2-a575-44ff-9319-9efbc11a9f6b)

*help*
```
Usage: ./reversednsscan.sh <ipaddress> <mask> [OPTIONS]
Options:
 -h --help      Display this help message
 -d --dns       Specify a dns server address
 -o --output    Save output to file

For example:
./reversednsscan.sh 10.10.10.10 30
./reversednsscan.sh 192.168.1.0 24 -d 192.168.1.1 -f output.txt
```

#### powershell
![2023-11-18_00-56](https://github.com/sergo2048/reversednsscaner/assets/40056618/aba7de06-37d9-4547-866d-e0ba31f20b15)

```powershell
.\reversednsscan.ps1 -ip "10.10.10.10" -mask 23 -server "10.10.10.1"
```

---
### TODO 
* сделать проверку что утилита host доступна если нет выход с сообщением как пофиксить 
* сделать параметры по умолчанию для bash и для powershell скрипта (по умолчанию dns сервер и адрес и сеть одного из интерфейсов)
* сделать вывод в файл для powerxhell
* сделать обработчик ошибок для параметорв в powershell
* Сделать чтобы можно было импортировать powershell как модуль 
* Добавить debug mode
