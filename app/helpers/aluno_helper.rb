module AlunoHelper
  def nivel_nome(nivel)
    User::NIVEIS.dig(nivel, :nome) || "Iniciante"
  end

  def nivel_color(nivel)
    User::NIVEIS.dig(nivel, :cor) || "#9CA3AF"
  end

  def proximo_nivel_xp(nivel)
    User::NIVEIS.dig(nivel, :limite_xp) || 1000
  end

  def xp_percentual(user)
    teto = proximo_nivel_xp(user.nivel).to_f
    [(user.xp_total / teto * 100).round, 100].min
  end
end