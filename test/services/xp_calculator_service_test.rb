require "test_helper"

class XpCalculatorServiceTest < ActiveSupport::TestCase
  test "gives more xp for more correct answers" do
    atividade = atividades(:leitura)

    baixo = XpCalculatorService.call(
      atividade: atividade,
      acertos: 0,
      total_perguntas: 2,
      tempo_gasto: 20,
      perfil_acessibilidade: "dislexia"
    )

    alto = XpCalculatorService.call(
      atividade: atividade,
      acertos: 2,
      total_perguntas: 2,
      tempo_gasto: 20,
      perfil_acessibilidade: "dislexia"
    )

    assert alto[:xp_ganho] > baixo[:xp_ganho]
  end

  test "applies profile bonus" do
    atividade = atividades(:desafio)

    sem_bonus = XpCalculatorService.call(
      atividade: atividade,
      acertos: 1,
      total_perguntas: 1,
      tempo_gasto: 8,
      perfil_acessibilidade: nil
    )

    com_bonus = XpCalculatorService.call(
      atividade: atividade,
      acertos: 1,
      total_perguntas: 1,
      tempo_gasto: 8,
      perfil_acessibilidade: "ambos"
    )

    assert com_bonus[:xp_ganho] > sem_bonus[:xp_ganho]
  end

  test "never returns zero xp for completed mission" do
    atividade = atividades(:foco)

    resultado = XpCalculatorService.call(
      atividade: atividade,
      acertos: 0,
      total_perguntas: 1,
      tempo_gasto: 200,
      perfil_acessibilidade: nil
    )

    assert resultado[:xp_ganho] >= 5
  end
end
