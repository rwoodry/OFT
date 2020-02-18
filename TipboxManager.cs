using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TipboxManager : MonoBehaviour
{
    public string text_targetobj = "Test";
    public Rect windowRect = new Rect(0, 0, Screen.width, Screen.height);
    public string text_help = "- WASD to move \n- SHIFT to run \n- ENTER when at object's center";
    public static string text_tip = "";
    private int height = (int)Mathf.Round(Screen.height / 50);
    private int width = (int)Mathf.Round(Screen.width / 50);



    // Start is called before the first frame update
    void Start()
    {
        windowRect = new Rect(0, 0, Mathf.Round(Screen.width /6) , Mathf.Round(Screen.height/7));
    }

    // Update is called once per frame
    void Update()
    {
        text_targetobj = LogManager.targetName;
        
    }

    private void OnGUI()
    {
        GUILayout.Window(0, windowRect, DisplayWindow, "Find the Target");

    }

    void DisplayWindow(int windowID)
    {
        GUIStyle myStyle = new GUIStyle();
        myStyle.fontSize = width;
        myStyle.fontStyle = FontStyle.Bold;
        myStyle.normal.textColor = Color.white;

        GUILayout.Label(("Target: " + text_targetobj), myStyle);

        myStyle.fontSize = height;
        myStyle.fontStyle = FontStyle.Normal;
        GUILayout.Label(text_help, myStyle);

        myStyle.fontStyle = FontStyle.BoldAndItalic;
        myStyle.fontSize = height + 5;
        GUILayout.Label(text_tip, myStyle);
    }
}
