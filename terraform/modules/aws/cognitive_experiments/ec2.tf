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
}