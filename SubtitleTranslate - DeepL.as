/*
        real time subtitle translate for PotPlayer using DeepLX
*/

// void OnInitialize()
// void OnFinalize()
// string GetTitle()                                                                                                    -> get title for UI
// string GetVersion                                                                                                    -> get version for manage
// string GetDesc()                                                                                                     -> get detail information
// string GetLoginTitle()                                                                                               -> get title for login dialog
// string GetLoginDesc()                                                                                                -> get desc for login dialog
// string GetUserText()                                                                                                 -> get user text for login dialog
// string GetPasswordText()                                                                                             -> get password text for login dialog
// string ServerLogin(string User, string Pass)                                                         -> login
// string ServerLogout()                                                                                                -> logout
//------------------------------------------------------------------------------------------------
// array<string> GetSrcLangs()                                                                                          -> get source language
// array<string> GetDstLangs()                                                                                          -> get target language
// string Translate(string Text, string &in SrcLang, string &in DstLang)        -> do translate !!

string JsonParse(string json) {
    JsonReader Reader;
    JsonValue Root;
    string ret = "";

    if (Reader.parse(json, Root) && Root.isObject()) {
        JsonValue data = Root["data"];
        if(data.isString()) {
            ret = data.asString();
        }
    }
    return ret;
}

array<string> LangTable = {
        "af",
        "sq",
        "am",
        "ar",
        "hy",
        "az",
        "eu",
        "be",
        "bn",
        "bs",
        "bg",
        "my",
        "ca",
        "ceb",
        "ny",
        "zh",
        "co",
        "hr",
        "cs",
        "da",
        "nl",
        "en",
        "eo",
        "et",
        "tl",
        "fi",
        "fr",
        "fy",
        "gl",
        "ka",
        "de",
        "el",
        "gu",
        "ht",
        "ha",
        "haw",
        "iw",
        "hi",
        "hmn",
        "hu",
        "is",
        "ig",
        "id",
        "ga",
        "it",
        "ja",
        "jw",
        "kn",
        "kk",
        "km",
        "ko",
        "ku",
        "ky",
        "lo",
        "la",
        "lv",
        "lt",
        "lb",
        "mk",
        "ms",
        "mg",
        "ml",
        "mt",
        "mi",
        "mr",
        "mn",
        "my",
        "ne",
        "no",
        "ps",
        "fa",
        "pl",
        "pt",
        "pa",
        "ro",
        "romanji",
        "ru",
        "sm",
        "gd",
        "sr",
        "st",
        "sn",
        "sd",
        "si",
        "sk",
        "sl",
        "so",
        "es",
        "su",
        "sw",
        "sv",
        "tg",
        "ta",
        "te",
        "th",
        "tr",
        "uk",
        "ur",
        "uz",
        "vi",
        "cy",
        "xh",
        "yi",
        "yo",
        "zu"
};

string UserAgent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36";

string GetTitle() {
        return "{$CP950=DeepLX 翻譯$}{$CP0=DeepLX translate$}";
}

string GetVersion() {
        return "1";
}

string GetDesc() {
        return "https://github.com/OwO-Network/DeepLX";
}

string GetLoginTitle() {
        return "DeepLX设置";
}

string GetLoginDesc() {
        return "设置DeepLX API地址和Token";
}

string GetUserText() {
        return "API地址: ";
}

string GetPasswordText() {
        return "Token: ";
}

string server_url;
string api_token;

string ServerLogin(string User, string Pass) {
        server_url = User;
        api_token = Pass;
        if (server_url.empty()) server_url = "https://api.deeplx.org";
        return "200 ok";
}

string ServerLogout() {
        server_url = "";
        api_token = "";
        return "200 ok";
}

array<string> GetSrcLangs() {
        array<string> ret = LangTable;

        ret.insertAt(0, ""); // empty is auto
        return ret;
}

array<string> GetDstLangs() {
        array<string> ret = LangTable;

        return ret;
}

string Translate(string Text, string &in SrcLang, string &in DstLang) {
    string url = server_url;
    
    // 去除尾部斜杠
    if(url.substr(url.length() - 1, 1) == "/") {
        url = url.substr(0, url.length() - 1);
    }
    
    // 添加token和translate路径
    if(!api_token.empty()) {
        url += "/" + api_token;
    }
    url += "/translate";

    Text.replace("\\","\\\\");
    Text.replace("\"","\\\"");
    Text.replace("\n","\\\\n");
    Text.replace("\r","\\\\r");
    Text.replace("\t","\\\\t");

    dictionary dict = {
        {'text', Text},
        {'target_lang', DstLang}
    };
    
    // 仅当源语言不为空时添加
    if(!SrcLang.empty()) {
        dict['source_lang'] = SrcLang;
    }
 
    string data = "{";
    data += DictionaryToString(dict);
    data += "}";

    string header = "Content-Type: application/json";
    
    string text = HostUrlGetStringWithAPI(url, UserAgent, header, data);
    
    string ret = JsonParse(text);
    
    if (ret.length() > 0) {
        SrcLang = "UTF8";
        DstLang = "UTF8";
        return ret;
    }

    return ret;
}

string DictionaryToString(dictionary dict) {
    array<string> keys = dict.getKeys();
    uint length = keys.length();
    array<string> pairs(length);
    for (uint i = 0; i < length; i++) {
        string key = keys[i];
        string value = string(dict[key]);
        pairs[i] = '"' + key + "\":\"" + value + '"';
    }
    string jsonString = join(pairs, ',');
    return jsonString;
}