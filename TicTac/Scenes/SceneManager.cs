public static class SceneManager
{
    public static Scene CurrentScene { get; private set; }

    public static void ChangeScene(Scene newScene, ContentManager content)
    {
        CurrentScene = newScene;
        CurrentScene.LoadContent(content);
    }
}
    