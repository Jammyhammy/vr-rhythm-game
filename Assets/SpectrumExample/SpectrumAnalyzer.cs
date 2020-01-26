using UnityEngine;

public class SpectrumAnalyzer : MonoBehaviour
{
    public AudioSource source;
    GameObject [] cubes;

    public Material material;

    public float SpectrumRefreshTime;
    private float lastUpdate = 0;
    private float[] spectrum = new float[256];
    public float scaleFactor = 10000;
    public float clipLoudness;

    void Start()
    {
        if(source == null)
        source = GetComponent<AudioSource>();
        cubes = new GameObject[256];
        createDisplayObjects();
    }

    void Update()
    {     
        if (Time.time - lastUpdate > SpectrumRefreshTime)
        {
            source.GetSpectrumData(spectrum, 0, FFTWindow.Rectangular);
            float levelMax = 0;
            for (int i = 0;i < spectrum.Length; i++)
            {

                float wavePeak = spectrum[i] * scaleFactor;
                if(levelMax < wavePeak) {
                    levelMax = wavePeak;
                }

                cubes[i].transform.localScale = new Vector3(0.5f, spectrum[i] * scaleFactor, 1);
            }
            clipLoudness = levelMax;
            lastUpdate = Time.time;
        }
    }

    void createDisplayObjects()
    {
        for (int i = 0; i < 256; i++)
        {
            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.GetComponent<MeshRenderer>().material = new Material(material);
            cube.GetComponent<MeshRenderer>().material.SetColor("_TintColor", new Color(Random.Range(0.25f,0.65f),0f, Mathf.Lerp(0.0f,0.75f,i/256f)));
            cube.transform.position = new Vector3(gameObject.transform.position.x + i / 2.0f, gameObject.transform.position.y, gameObject.transform.position.z);
            cubes[i] = cube;
        }
    }
}