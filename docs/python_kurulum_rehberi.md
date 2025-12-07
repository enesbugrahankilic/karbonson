# Python Kurulum Rehberi (macOS)

## Gereksinimler

AI API'sini çalıştırmak için Python ve pip paket yöneticisinin sistemde kurulu olması gerekir.

## Python Kurulumu

### Yöntem 1: Homebrew ile Kurulum (Önerilen)

1. Homebrew'i kurun (eğer zaten kurulu değilse):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Python'u kurun:
```bash
brew install python
```

### Yöntem 2: Python.org'dan İndirme

1. [Python.org](https://www.python.org/downloads/macos/) adresinden macOS için en son Python sürümünü indirin.
2. İndirilen `.pkg` dosyasını çalıştırarak kurulumu tamamlayın.

## Pip Kurulumu

Python kurulduktan sonra, pip genellikle otomatik olarak kurulur. Eğer kurulmamışsa:

```bash
python -m ensurepip --upgrade
```

## Kurulum Doğrulama

Python ve pip'in doğru şekilde kurulduğunu doğrulamak için:

```bash
python --version
pip --version
```

## Sanal Ortam Oluşturma (İsteğe Bağlı)

Proje için ayrı bir sanal ortam oluşturmak isterseniz:

```bash
python -m venv ai_env
source ai_env/bin/activate
```

Sanal ortamı etkinleştirdikten sonra, gerekli paketleri yükleyebilirsiniz:

```bash
pip install -r python_api/requirements.txt
```

## AI API'sini Çalıştırma

Python kurulduktan sonra AI API'sini çalıştırmak için:

```bash
cd python_api
pip install -r requirements.txt
python ai_api.py
```

## Test Çalıştırma

API'yi test etmek için:

```bash
cd python_api
pytest test_ai_api.py
```

veya

```bash
bash test_api.sh