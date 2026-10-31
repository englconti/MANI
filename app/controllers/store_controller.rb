# The Mani Store: avatars bought with the M$ earned in the lessons
class StoreController < ApplicationController
  def index
    @avatars = Avatar.all
    @owned_keys = current_user.owned_avatar_keys
    @manis = current_user.manis
  end

  def purchase
    avatar = Avatar.find!(params[:key])
    current_user.buy_avatar!(avatar)
    redirect_to store_path, notice: "Você comprou o avatar #{avatar.name}! Toque em Usar para colocá-lo no seu perfil."
  rescue Avatar::NotEnoughManis => error
    redirect_to store_path, alert: "Faltam #{error.missing} M$ para comprar esse avatar."
  rescue Avatar::AlreadyOwned
    redirect_to store_path, alert: "Você já tem esse avatar."
  rescue Avatar::Unknown
    redirect_to store_path, alert: "Esse avatar não existe na loja."
  end

  def use
    avatar = Avatar.find!(params[:key])
    current_user.use_avatar!(avatar)
    redirect_to store_path, notice: "Agora você usa o avatar #{avatar.name}."
  rescue Avatar::NotOwned
    redirect_to store_path, alert: "Compre o avatar antes de usá-lo."
  rescue Avatar::Unknown
    redirect_to store_path, alert: "Esse avatar não existe na loja."
  end
end
