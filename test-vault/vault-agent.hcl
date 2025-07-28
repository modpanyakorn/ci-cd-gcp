pid_file = "vault-agent.pid"

auto_auth {
  method "approle" {
    mount_path = "auth/approle"
    config = {
      role_id_file_path   = "role_id.txt"
      secret_id_file_path = "secret_id.txt"
    }
  }

  sink "file" {
    config = {
      path = "/tmp/vault-token"
    }
  }
}

vault {
  address = "http://127.0.0.1:8200"
}
