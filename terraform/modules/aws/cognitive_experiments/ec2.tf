# 公式Docのexample参照：https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#example-usage
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"] # 最近のインスタンスは大体これらしい
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "socialbandit" # TODO: 変数としてtfvarsに指定できるようにする

  security_groups = ["SocialBanditExpGroup"] # TODO: 変数として指定できるようにする

  tags = {
    Name = "terraform-social-bandit-server-1"  # インスタンスの名前をタグで指定
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"  # AMIに合わせて変更（例: Ubuntuではubuntu）
    private_key = file("/path/to/local/private-key.pem")
    host        = aws_instance.web.public_ip
  }

  # Gitのインストールとファイル転送をまとめて行う
  provisioner "remote-exec" {
    inline = [
      "apt-get update",  # パッケージリストを更新
      "apt-get install -y git",  # Gitのインストール
      "chmod 600 /home/ec2-user/.ssh/github",  # GitHub SSHキーの権限設定
      "git clone git@github.com:user/repo.git /path/to/clone"  # Gitのクローン操作
    ]
  }

  # SSHキーをインスタンスにアップロード
  provisioner "file" {
    source      = "~/.ssh/github"  # ローカルのGitHub SSHキー
    destination = "/home/ec2-user/.ssh/github"  # EC2インスタンス内の保存先
  }

  # .gitconfigファイルをインスタンスにアップロード
  provisioner "file" {
    source      = "~/.gitconfig"  # ローカルのGit設定ファイル
    destination = "/home/ec2-user/.gitconfig"  # EC2インスタンス内の保存先
  }
}