module generator.generator;

import std.stdio : writeln, writefln;
import std.string : format;
import generator.parser : TelegramEntity, TelegramType, TelegramMethod;
import std.array : assocArray;
import std.algorithm.iteration;

static string[string] entityModuleMap;

shared static this()
{
    string[] basic = [
        // types
        "User", "Chat", "Message", "Update",
        // methods
    ];
    string[] groupchat = [
        // types
        // methods
    ];
    string[] games = [
        // types
        "Game", "Animation", "CallbackGame", "GameHighScore",
        // methods
    ];

    basic.each!(val => entityModuleMap[val] = basic.stringof);
    games.each!(val => entityModuleMap[val] = games.stringof);
}

class CodeGenerator
{
    private string modulesDir = "telegram";

    public this(string modulesDir)
    {
        this.modulesDir = modulesDir;
    }

    public void generateFiles(TelegramEntity[string] entities)
    {
        foreach (entity; entities) {
            if (cast(TelegramType)entity) {
                generateType(cast(TelegramType)entity).writeln();
            } else if (cast(TelegramMethod)entity) {
                generateMethod(cast(TelegramMethod)entity).writeln();
            } else {
                assert(false, "Unknown entity " ~ entity.name);
            }
        }
        //writeln(entityModuleMap);
    }

    private string generateType(TelegramType entity)
    {
        StructItem item = StructItem(entity.name);

        return item.toString();
    }

    private string generateMethod(TelegramMethod entity)
    {
        return "TODO";
    }

}

struct StructItem
{
    private string name;
    private StructItemField[] fields;

    public this(string name)
    {
        this.name = name;
    }

    public void addField(StructItemField field)
    {
        fields ~= field;
    }

    public string toString()
    {
        return format("///\nstruct %s\n{\n%s\n}\n", name, fieldsToString());
    }

    private string fieldsToString()
    {
        return "";
    }
}

struct StructItemField
{

}