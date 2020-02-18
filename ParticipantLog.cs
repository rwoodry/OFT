using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.IO;
using TMPro;


public class ParticipantLog : MonoBehaviour
{
    public static string user, file_name_pos, file_name_obj;
    public GameObject canvas;
    Text userNameInputText;
    public Button overwriteButton, appendButton;
    public TextMeshProUGUI fileExists;
    public static bool trialResponseCollected = false;
    public static bool readyForNextTrial = false;
    public Randomizev2 m_Randomizev2;
    public static int trialPhase = 1;
    
    


    // Start is called before the first frame update
    void Start()
    {
        userNameInputText = canvas.transform.Find("InputField/Text").GetComponent<Text>();
        m_Randomizev2 = GameObject.FindObjectOfType(typeof(Randomizev2)) as Randomizev2;
        overwriteButton.onClick.AddListener(OverwriteFile);
        appendButton.onClick.AddListener(AppendFile);


        /*var input = gameObject.GetComponent<InputField>();
        var se = new InputField.SubmitEvent();
        se.AddListener(SubmitName);
        input.onEndEdit = se;*/

    }


    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Return))
        {
            
            SubmitID();
        }
    }

    public void SubmitID()
    {
        user = userNameInputText.text;
        Debug.Log("Check check: " + user);
        file_name_pos = user + "_position.csv";
        file_name_obj = user + "_objdistance.csv";
        if (File.Exists(file_name_pos))
        {
            Debug.Log("File exists");
            overwriteButton.gameObject.SetActive(true);
            appendButton.gameObject.SetActive(true);
            fileExists.gameObject.SetActive(true);

        } else
        {
            readyForNextTrial = true;
            m_Randomizev2.NextScene();
            Debug.Log("Success!");
        }

    }

    public void OverwriteFile()
    {
        File.Delete(file_name_pos);
        File.Delete(file_name_obj);


        m_Randomizev2.NextScene();
        Debug.Log(user + " deleted");
    }

    public void AppendFile()
    {

        m_Randomizev2.NextScene();
        Debug.Log(user + " appended");
    }
}
