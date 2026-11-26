
#include <a_samp>

#define DIALOG_REGISTRO 1000
#define DIALOG_LOGIN 1001

new bool:Logado[MAX_PLAYERS];
new Tentativas[MAX_PLAYERS];
new Text:ZikaLogo;

stock MostrarRegistro(playerid)
{
    new nome[MAX_PLAYER_NAME], titulo[80];

    GetPlayerName(playerid, nome, sizeof(nome));
    format(titulo, sizeof(titulo), "ZIKA RP - Cadastro: %s", nome);

    ShowPlayerDialog(playerid, DIALOG_REGISTRO,
        DIALOG_STYLE_PASSWORD,
        titulo,
        "Bem-vindo a ZIKA RP!\nCrie uma senha para sua conta:",
        "Cadastrar", "Sair");
    return 1;
}

stock MostrarLogin(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_LOGIN,
        DIALOG_STYLE_PASSWORD,
        "ZIKA RP - Login",
        "Sua conta ja existe!\nDigite sua senha para entrar:",
        "Entrar", "Sair");
    return 1;
}

stock SalvarConta(playerid, const senha[])
{
    new nome[MAX_PLAYER_NAME];
    new arquivo[64];
    new hash[65];
    new File:handle;

    GetPlayerName(playerid, nome, sizeof(nome));
    format(arquivo, sizeof(arquivo), "%s.ini", nome);

    SHA256_PassHash(senha, nome, hash, sizeof(hash));

    handle = fopen(arquivo, io_write);

    if (!handle) return 0;

    fwrite(handle, hash);
    fclose(handle);

    return 1;
}

stock VerificarSenha(playerid, const senha[])
{
    new nome[MAX_PLAYER_NAME];
    new arquivo[64];
    new hash[65];
    new hashSalvo[65];
    new File:handle;

    GetPlayerName(playerid, nome, sizeof(nome));
    format(arquivo, sizeof(arquivo), "%s.ini", nome);

    handle = fopen(arquivo, io_read);

    if (!handle) return 0;

    fread(handle, hashSalvo, sizeof(hashSalvo));
    fclose(handle);

    SHA256_PassHash(senha, nome, hash, sizeof(hash));

    if (strcmp(hash, hashSalvo, false) == 0)
        return 1;

    return 0;
}

main()
{
    print("================================");
    print("          ZIKA ROLEPLAY");
    print("       Servidor iniciado!");
    print("================================");
}

public OnGameModeInit()
{
    SetGameModeText("ZIKA RP - Mobile");

    AddPlayerClass(
        0,
        1481.0, -1771.0, 18.8,
        90.0,
        0, 0, 0, 0, 0, 0
    );

    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    ShowNameTags(true);
    SetWorldTime(12);
    SetWeather(1);

    ZikaLogo = TextDrawCreate(320.0, 12.0, "ZIKA RP");
    TextDrawAlignment(ZikaLogo, 2);
    TextDrawLetterSize(ZikaLogo, 0.50, 1.80);
    TextDrawColor(ZikaLogo, 0x00E5FFFF);
    TextDrawSetOutline(ZikaLogo, 2);
    TextDrawSetShadow(ZikaLogo, 1);
    TextDrawFont(ZikaLogo, 2);
    TextDrawSetProportional(ZikaLogo, 1);
    TextDrawSetSelectable(ZikaLogo, 0);

    print("[ZIKA RP] Sistema carregado!");

    return 1;
}

public OnPlayerConnect(playerid)
{
    new nome[MAX_PLAYER_NAME];
    new arquivo[64];

    Logado[playerid] = false;
    Tentativas[playerid] = 0;

    GetPlayerName(playerid, nome, sizeof(nome));
    format(arquivo, sizeof(arquivo), "%s.ini", nome);

    TogglePlayerSpectating(playerid, true);

    if (fexist(arquivo))
    {
        MostrarLogin(playerid);
    }
    else
    {
        MostrarRegistro(playerid);
    }

    SendClientMessage(playerid, 0x00E5FFFF,
        "Bem-vindo a ZIKA RP!");

    return 1;
}

public OnDialogResponse(playerid, dialogid, response,
    listitem, inputtext[])
{
    if (dialogid == DIALOG_REGISTRO)
    {
        if (!response)
        {
            Kick(playerid);
            return 1;
        }

        if (strlen(inputtext) < 4)
        {
            SendClientMessage(playerid, 0xFF0000FF,
                "A senha precisa ter pelo menos 4 caracteres.");
            MostrarRegistro(playerid);
            return 1;
        }

        if (!SalvarConta(playerid, inputtext))
        {
            SendClientMessage(playerid, 0xFF0000FF,
                "Erro ao salvar sua conta.");
            Kick(playerid);
            return 1;
        }

        SendClientMessage(playerid, 0x00FF00FF,
            "Conta criada com sucesso!");

        Logado[playerid] = true;
        TogglePlayerSpectating(playerid, false);
        SpawnPlayer(playerid);

        return 1;
    }

    if (dialogid == DIALOG_LOGIN)
    {
        if (!response)
        {
            Kick(playerid);
            return 1;
        }

        if (VerificarSenha(playerid, inputtext))
        {
            Logado[playerid] = true;

            SendClientMessage(playerid, 0x00FF00FF,
                "Login realizado com sucesso!");

            TogglePlayerSpectating(playerid, false);
            SpawnPlayer(playerid);
        }
        else
        {
            Tentativas[playerid]++;

            if (Tentativas[playerid] >= 3)
            {
                SendClientMessage(playerid, 0xFF0000FF,
                    "Muitas senhas incorretas.");
                Kick(playerid);
            }
            else
            {
                SendClientMessage(playerid, 0xFF0000FF,
                    "Senha incorreta! Tente novamente.");
                MostrarLogin(playerid);
            }
        }

        return 1;
    }

    return 0;
}

public OnPlayerSpawn(playerid)
{
    if (!Logado[playerid])
    {
        TogglePlayerSpectating(playerid, true);
        return 1;
    }

    TextDrawShowForPlayer(playerid, ZikaLogo);

    SendClientMessage(playerid, 0x00FFFFFF,
        "Divirta-se na cidade ZIKA RP!");

    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!Logado[playerid])
        return 1;

    if (strcmp(cmdtext, "/ajuda", true) == 0)
    {
        SendClientMessage(playerid, 0xFFFF00FF,
            "COMANDOS: /vida /colete /spawn");
        return 1;
    }

    if (strcmp(cmdtext, "/vida", true) == 0)
    {
        SetPlayerHealth(playerid, 100.0);
        SendClientMessage(playerid, 0x00FF00FF,
            "Sua vida foi restaurada!");
        return 1;
    }

    if (strcmp(cmdtext, "/colete", true) == 0)
    {
        SetPlayerArmour(playerid, 100.0);
        SendClientMessage(playerid, 0x00FF00FF,
            "Colete completo!");
        return 1;
    }

    if (strcmp(cmdtext, "/spawn", true) == 0)
    {
        SpawnPlayer(playerid);
        return 1;
    }

    return 0;
}

public OnPlayerDisconnect(playerid, reason)
{
    Logado[playerid] = false;
    Tentativas[playerid] = 0;
    return 1;
}
