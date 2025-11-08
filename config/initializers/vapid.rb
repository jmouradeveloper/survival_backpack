# VAPID keys para Web Push Notifications
# Public key está no layout (meta tag)
# Private key aqui para uso no servidor

Rails.application.config.vapid_keys = {
  public_key: "BGPQxnL5eWKvTY7_aa1CsEsxdulj9c3MrQowgzkwBiNFHch-KQ9VGzZy9J_2C7aau3nc7vYjdprAM8ymzzfzaAU",
  private_key: "_fzOlu45fkkQTu_IKzGiYqevZ6EVJOdtDcS0g7acSv8"
}

# Em produção, você deve mover estas chaves para:
# - Variáveis de ambiente (ENV)
# - Rails credentials (rails credentials:edit)
# - Ou outro sistema de secrets management

