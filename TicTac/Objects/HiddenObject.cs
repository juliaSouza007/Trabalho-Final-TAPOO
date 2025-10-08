public class HiddenObject
{
    public string Nome { get; private set; }
    public Rectangle Area { get; private set; }
    public bool Encontrado { get; set; }

    public HiddenObject(string nome, Rectangle area)
    {
        Nome = nome;
        Area = area;
        Encontrado = false;
    }

    public void Draw(SpriteBatch spriteBatch)
    {
        if (!Encontrado)
        {
            // Opcional: desenhar uma leve transparência ou marcador de debug
            // spriteBatch.Draw(texture, Area, Color.White * 0.5f);
        }
    }
}
