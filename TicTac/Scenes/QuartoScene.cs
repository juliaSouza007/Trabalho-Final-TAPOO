public class QuartoScene : Scene
{
    private Texture2D background;
    private List<HiddenObject> objetos;
    private SpriteFont fonte;
    private int encontrados = 0;

    public override void LoadContent(ContentManager content)
    {
        background = content.Load<Texture2D>("Textures/quarto");
        fonte = content.Load<SpriteFont>("Fonts/DefaultFont");

        objetos = new List<HiddenObject>()
        {
            new HiddenObject("Celular quebrado", new Rectangle(150, 320, 64, 64)),
            new HiddenObject("Foto esquecida", new Rectangle(400, 450, 64, 64)),
            new HiddenObject("Agenda", new Rectangle(700, 200, 64, 64))
        };
    }

    public override void Update(GameTime gameTime)
    {
        if (Mouse.GetState().LeftButton == ButtonState.Pressed)
        {
            var pos = Mouse.GetState().Position;
            foreach (var obj in objetos.Where(o => !o.Encontrado))
            {
                if (obj.Area.Contains(pos))
                {
                    obj.Encontrado = true;
                    encontrados++;
                }
            }
        }

        // Exemplo: se todos forem encontrados
        if (encontrados == objetos.Count)
        {
            // trocar de cena
            SceneManager.ChangeScene(new EscolaScene(), Game1.Content);
        }
    }

    public override void Draw(SpriteBatch spriteBatch)
    {
        spriteBatch.Draw(background, Vector2.Zero, Color.White);
        foreach (var obj in objetos)
            obj.Draw(spriteBatch);

        spriteBatch.DrawString(fonte, $"Encontrados: {encontrados}/{objetos.Count}", new Vector2(20, 20), Color.White);
    }
}
