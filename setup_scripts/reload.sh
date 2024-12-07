# 実行インスタンスのパブリックIPを取得
new_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Public IP address is: $new_ip"

# nginxの設定ファイルbanditのip変更
line="server_name ${new_ip};"
sudo sed -i -e "7s/server_name.*/${line}/g" "/etc/nginx/sites-available/bandit"

# settings.pyのip変更
line="ALLOWED_HOSTS = ['${new_ip}', '127.0.0.1']"
sudo sed -i -e "29s/.*/${line}/g" "/home/ubuntu/social-bandit-ex/bandit/settings.py"

# gunicorn周り
sudo systemctl daemon-reload
sudo systemctl restart gunicorn.service
sudo systemctl restart gunicorn.socket

# django周り
python3 manage.py migrate
sudo python3 manage.py collectstatic

# nginx周り
sudo service nginx restart