
#include <a_samp>

// ============================================================
// ZK RP MOBILE - GAMEMODE RECONSTRUIDO
// ============================================================

#define ZK_SERVIDOR "ZK RP | Mobile Roleplay"
#define ZK_DONO "Fhzk"
#define ZK_SENHA_DONO "TROQUE_POR_UMA_SENHA_PRIVADA"

#define COR_BRANCO 0xFFFFFFFF
#define COR_ROXO 0x9B5CFFFF
#define COR_VERDE 0x20D879FF
#define COR_VERMELHO 0xFF4444FF
#define COR_CIANO 0x00E5FFFF
#define COR_DOURADO 0xFFD700FF

#define MAX_CASAS 5

#define DINHEIRO_INICIAL 2500

#define DIALOG_REGISTRO 1000
#define DIALOG_LOGIN 1001
#define DIALOG_MENU 1002
#define DIALOG_EMPREGOS 1003
#define DIALOG_GPS 1004
#define DIALOG_BANCO 1005
#define DIALOG_CASAS 1006
#define DIALOG_MERCADO 1007
#define DIALOG_ROUPAS 1008
#define DIALOG_VEICULO 1009
#define DIALOG_DONO_LOGIN 1010
#define DIALOG_DONO 1011
#define DIALOG_STATUS 1012

#define EMPREGO_NENHUM 0
#define EMPREGO_ENTREGADOR 1
#define EMPREGO_ONIBUS 2
#define EMPREGO_POLICIAL 3
#define EMPREGO_MECANICO 4

enum E_PLAYER
{
    bool:Logado,
    SenhaHash[65],
    Dinheiro,
    Banco,
    Nivel,
    Experiencia,
    Fome,
    Sede,
    Emprego,
    Skin,
    bool:CNH,
    Casa,
    bool:Trabalhando,
    VeiculoTrabalho
};

new Dados[MAX_PLAYERS][E_PLAYER];

enum E_CASA
{
    Float:CasaX,
    Float:CasaY,
    Float:CasaZ,
    Preco,
    bool:Comprada,
    Dono[MAX_PLAYER_NAME]
};

new Casas[MAX_CASAS][E_CASA];

new Nome[MAX_PLAYERS][MAX_PLAYER_NAME];
new StringTemporaria[256];

// ============================================================
// FUNCOES BASICAS
// ============================================================

stock Mensagem(playerid, cor, const texto[])
{
    SendClientMessage(playerid, cor, texto);
    return 1;
}

stock bool:EhDono(playerid)
{
    GetPlayerName(playerid, Nome[playerid], MAX_PLAYER_NAME);

    if (strcmp(Nome[playerid], ZK_DONO, true) == 0)
        return true;

    return false;
}

stock InicializarDados(playerid)
{
    Dados[playerid][Logado] = false;
    Dados[playerid][Dinheiro] = DINHEIRO_INICIAL;
    Dados[playerid][Banco] = 0;
    Dados[playerid][Nivel] = 1;
    Dados[playerid][Experiencia] = 0;
    Dados[playerid][Fome] = 100;
    Dados[playerid][Sede] = 100;
    Dados[playerid][Emprego] = EMPREGO_NENHUM;
    Dados[playerid][Skin] = 7;
    Dados[playerid][CNH] = false;
    Dados[playerid][Casa] = -1;
    Dados[playerid][Trabalhando] = false;
    Dados[playerid][VeiculoTrabalho] = INVALID_VEHICLE_ID;
    Dados[playerid][SenhaHash][0] = EOS;
    return 1;
}

stock RetirarDinheiro(playerid, valor)
{
    if (Dados[playerid][Dinheiro] < valor)
        return 0;

    Dados[playerid][Dinheiro] -= valor;
    return 1;
}

stock NomeEmprego(emprego)
{
    switch (emprego)
    {
        case EMPREGO_ENTREGADOR: return "Entregador";
        case EMPREGO_ONIBUS: return "Motorista de onibus";
        case EMPREGO_POLICIAL: return "Policial";
        case EMPREGO_MECANICO: return "Mecanico";
    }
    return "Desempregado";
}

// ============================================================
// SISTEMA DE CONTAS
// ============================================================

stock ArquivoConta(playerid, destino[], tamanho)
{
    format(destino, tamanho, "Contas/%s.ini", Nome[playerid]);
    return 1;
}

stock SalvarConta(playerid)
{
    if (!Dados[playerid][Logado])
        return 0;

    new arquivo[64];
    ArquivoConta(playerid, arquivo, sizeof(arquivo));

    new File:conta = fopen(arquivo, io_write);

    if (!conta)
        return 0;

    format(StringTemporaria, sizeof(StringTemporaria), "%s\n", Dados[playerid][SenhaHash]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Dinheiro]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Banco]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Nivel]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Experiencia]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Fome]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Sede]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Emprego]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Skin]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][CNH]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Casa]);
    fwrite(conta, StringTemporaria);

    fclose(conta);
    return 1;
}

// ============================================================
// PARTE 2/4 - CARREGAMENTO, LOGIN E MENUS
// ============================================================

stock CarregarConta(playerid)
{
    new arquivo[64];
    ArquivoConta(playerid, arquivo, sizeof(arquivo));

    if (!fexist(arquivo))
        return 0;

    new File:conta = fopen(arquivo, io_read);
    if (!conta)
        return 0;

    new linha[128];

    fread(conta, linha);
    format(Dados[playerid][SenhaHash], 65, "%s", linha);

    fread(conta, linha);
    Dados[playerid][Dinheiro] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Banco] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Nivel] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Experiencia] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Fome] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Sede] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Emprego] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Skin] = strval(linha);

    fread(conta, linha);
    Dados[playerid][CNH] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Casa] = strval(linha);

    fclose(conta);
    return 1;
}

stock MostrarRegistro(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_REGISTRO,
        DIALOG_STYLE_PASSWORD,
        "{9B5CFF}ZK RP - Registro",
        "Bem-vindo ao ZK RP!\n\nCrie uma senha para sua conta:",
        "Registrar", "Sair");
    return 1;
}

stock MostrarLogin(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_LOGIN,
        DIALOG_STYLE_PASSWORD,
        "{9B5CFF}ZK RP - Login",
        "Digite sua senha para entrar no servidor:",
        "Entrar", "Sair");
    return 1;
}

stock AbrirMenu(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_MENU,
        DIALOG_STYLE_LIST,
        "{9B5CFF}ZK RP - Menu principal",
        "Meu personagem\nEmpregos\nGPS\nBanco\nMercado\nRoupas e CNH\nImoveis\nVeiculo",
        "Selecionar", "Fechar");
    return 1;
}

stock AbrirEmpregos(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_EMPREGOS,
        DIALOG_STYLE_LIST,
        "{9B5CFF}Central de empregos",
        "Entregador\nMotorista de onibus\nPolicial\nMecanico\nPedir demissao",
        "Selecionar", "Voltar");
    return 1;
}

stock AbrirGPS(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS,
        DIALOG_STYLE_LIST,
        "{9B5CFF}GPS Mobile",
        "Prefeitura\nAgencia de empregos\nConcessionaria\nLoja de roupas\nHospital\nMinha casa\nCancelar GPS",
        "Marcar", "Voltar");
    return 1;
}

stock AbrirBanco(playerid)
{
    format(StringTemporaria, sizeof(StringTemporaria),
        "Depositar $500\nDepositar $1000\nSacar $500\nSacar $1000\nConsultar saldo\n\nDinheiro: $%d | Banco: $%d",
        Dados[playerid][Dinheiro],
        Dados[playerid][Banco]);

    ShowPlayerDialog(playerid, DIALOG_BANCO,
        DIALOG_STYLE_LIST,
        "{9B5CFF}Banco ZK",
        StringTemporaria,
        "Selecionar", "Voltar");
    return 1;
}

stock AbrirCasas(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_CASAS,
        DIALOG_STYLE_LIST,
        "{9B5CFF}Imoveis disponiveis",
        "Casa 01 - $15.000\nCasa 02 - $25.000\nCasa 03 - $40.000\nCasa 04 - $50.000\nCasa 05 - $65.000",
        "Comprar", "Voltar");
    return 1;
}

// ============================================================
// SISTEMA DE CASAS
// ============================================================

stock InicializarCasas()
{
    Casas[0][CasaX] = 2495.0;
    Casas[0][CasaY] = -1691.2;
    Casas[0][CasaZ] = 13.5;
    Casas[0][Preco] = 15000;

    Casas[1][CasaX] = 2468.0;
    Casas[1][CasaY] = -1698.0;
    Casas[1][CasaZ] = 13.5;
    Casas[1][Preco] = 25000;

    Casas[2][CasaX] = 2447.0;
    Casas[2][CasaY] = -1702.0;
    Casas[2][CasaZ] = 13.5;
    Casas[2][Preco] = 40000;

    Casas[3][CasaX] = 2380.0;
    Casas[3][CasaY] = -1710.0;
    Casas[3][CasaZ] = 13.5;
    Casas[3][Preco] = 50000;

    Casas[4][CasaX] = 2310.0;
    Casas[4][CasaY] = -1640.0;
    Casas[4][CasaZ] = 14.0;
    Casas[4][Preco] = 65000;

    for (new i = 0; i < MAX_CASAS; i++)
    {
        Casas[i][Comprada] = false;
        Casas[i][Dono][0] = EOS;
    }
    return 1;
}

// ============================================================
// SISTEMA DE EXPERIENCIA
// ============================================================

stock VerificarNivel(playerid)
{
    while (Dados[playerid][Experiencia] >= Dados[playerid][Nivel] * 100)
    {
        Dados[playerid][Experiencia] -= Dados[playerid][Nivel] * 100;
        Dados[playerid][Nivel]++;

        format(StringTemporaria, sizeof(StringTemporaria),
            "Parabens! Voce alcancou o nivel %d.",
            Dados[playerid][Nivel]);

        Mensagem(playerid, COR_DOURADO, StringTemporaria);
    }
    return 1;
}

// ============================================================
// SISTEMA DE TRABALHO
// ============================================================

stock IniciarTrabalho(playerid)
{
    if (Dados[playerid][Emprego] == EMPREGO_NENHUM)
    {
        Mensagem(playerid, COR_VERMELHO,
            "Voce precisa escolher um emprego primeiro.");
        return 0;
    }

    if (Dados[playerid][Trabalhando])
    {
        Mensagem(playerid, COR_VERMELHO,
            "Voce ja esta trabalhando.");
        return 0;
    }

    Dados[playerid][Trabalhando] = true;

    Mensagem(playerid, COR_VERDE,
        "Trabalho iniciado! Use /finalizar para receber.");

    if (Dados[playerid][Emprego] == EMPREGO_ENTREGADOR)
    {
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);

        Dados[playerid][VeiculoTrabalho] =
            CreateVehicle(462, x + 3.0, y, z, 90.0, 1, 1, -1);

        if (Dados[playerid][VeiculoTrabalho] != INVALID_VEHICLE_ID)
        {
            PutPlayerInVehicle(playerid,
                Dados[playerid][VeiculoTrabalho], 0);
        }
    }
    return 1;
}

stock FinalizarTrabalho(playerid)
{
    if (!Dados[playerid][Trabalhando])
    {
        Mensagem(playerid, COR_VERMELHO,
            "Voce nao iniciou um trabalho.");
        return 0;
    }

    Dados[playerid][Trabalhando] = false;

    new recompensa = 500 + random(501);

    Dados[playerid][Dinheiro] += recompensa;
    Dados[playerid][Experiencia] += 25;

    format(StringTemporaria, sizeof(StringTemporaria),
        "Trabalho finalizado! Voce recebeu $%d.",
        recompensa);

    Mensagem(playerid, COR_VERDE, StringTemporaria);

    if (Dados[playerid][VeiculoTrabalho] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(Dados[playerid][VeiculoTrabalho]);
        Dados[playerid][VeiculoTrabalho] = INVALID_VEHICLE_ID;
    }

    VerificarNivel(playerid);
    SalvarConta(playerid);
    return 1;
}

// ============================================================
// PAINEL DO DONO
// ============================================================

stock AbrirPainelDono(playerid)
{
    if (!EhDono(playerid))
    {
        Mensagem(playerid, COR_VERMELHO,
            "Somente o dono pode acessar este painel.");
        return 0;
    }

    ShowPlayerDialog(playerid, DIALOG_DONO,
        DIALOG_STYLE_LIST,
        "{FFD700}[DONO] Painel administrativo",
        "Criar Sultan\nCriar Infernus\nCriar NRG-500\nIr para Prefeitura\nIr para Agencia\nRecuperar vida\nReceber $10.000\nAtivar jetpack\nDesativar jetpack",
        "Executar", "Fechar");
    return 1;
}

stock CriarVeiculoDono(playerid, modelo)
{
    new Float:x, Float:y, Float:z, Float:a;

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new veiculo = CreateVehicle(modelo,
        x + 3.0, y, z, a, -1, -1, -1);

    if (veiculo != INVALID_VEHICLE_ID)
        PutPlayerInVehicle(playerid, veiculo, 0);

    return 1;
}
