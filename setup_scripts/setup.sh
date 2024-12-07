# 先にgitのkeyを作成しておく
# 実行インスタンスのパブリックIPを取得
new_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# apt-getのアップデート
sudo apt-get update
# 必要なライブラリのインストール
sudo apt-get install -y python3-django gunicorn nginx python3-numpy

# gunicorn.serviceの作成
sudo mv -f ws_settings/gunicorn.service /etc/systemd/system

# gunicorn.socketの作成
sudo mv -f ws_settings/gunicorn.socket /etc/systemd/system

# nginxの設定ファイルbanditを作成
sudo mv -f ws_settings/bandit /etc/nginx/sites-available
line="server_name ${new_ip};"
sudo sed -i -e "7s/server_name.*/${line}/g" "/etc/nginx/sites-available/bandit"
sudo ln -s /etc/nginx/sites-available/bandit /etc/nginx/sites-enabled/


# settings.pyのipを変更
line="ALLOWED_HOSTS = ['${new_ip}', '127.0.0.1']"
sudo sed -i -e "29s/.*/${line}/g" "/home/ubuntu/social-bandit-ex/bandit/settings.py"

# nginx用の静的ファイル格納場所を作成
sudo mkdir /usr/share/nginx/html/static
sudo mkdir /usr/share/nginx/html/media

# djangoの準備
python3 manage.py migrate
sudo python3 manage.py collectstatic

# gunicornの起動
sudo systemctl start gunicorn
sudo systemctl enable gunicorn

# nginxの起動
sudo service nginx restart