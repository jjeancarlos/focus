module AlunoHelper
  NIVEIS = {
    1 => { nome: "Iniciante",      cor: "#9CA3AF" },
    2 => { nome: "Explorador",     cor: "#4A8C5C" },
    3 => { nome: "Focado",         cor: "#4A6FA5" },
    4 => { nome: "Determinado",    cor: "#7C5CBF" },
    5 => { nome: "Mestre do Foco", cor: "#9C7A2E" }
  }.freeze

  XP_NIVEIS = { 1 => 100, 2 => 250, 3 => 500, 4 => 1000, 5 => 1000 }.freeze

  def nivel_nome(nivel)
    NIVEIS.dig(nivel, :nome) || "Iniciante"
  end

  def nivel_color(nivel)
    NIVEIS.dig(nivel, :cor) || "#9CA3AF"
  end

  def proximo_nivel_xp(nivel)
    XP_NIVEIS[nivel] || 1000
  end

  def xp_percentual(user)
    teto = proximo_nivel_xp(user.nivel).to_f
    [(user.xp_total / teto * 100).round, 100].min
  end
end