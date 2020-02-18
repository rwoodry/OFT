using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System.Collections;
using UnityStandardAssets.Characters.FirstPerson;
using System.IO;


public class LogManager : MonoBehaviour
{
    string FILE_NAME = "test";
    string OBJ_FILE_NAME = "test";
    private GameObject object31, object32;
    public static Vector3 playerPos;
    public Vector3 playerRot;
    private FirstPersonController fps;
    private static bool created = false;
    public GameObject[] targetsWithTag;
    public GameObject target, spawn;
    private GameObject targetObject;
    public Vector3 playerStart;
    public static float delayTime;
    public Randomizev2 m_Randomizev2;
    public static float totalDistanceTraveled = 0f;
    public float totalDegreesRotatedY = 0f;
    public float totalDegreesRotatedW = 0f;
    public static float tdrAngle = 0f;
    public float avgSpeed = 0f;
    public float sumSpeed = 0f;
    public int cpdIteration = 0;
    public static Vector3 lastPosition = Vector3.zero;
    public Vector3 lastRotation, lastAngle, playerRotAngle;
    // public Text targetText;
    public static float radiusThreshold = 5;
    public static string targetName;
    public static bool newTrial = false;
    public bool target_visible;
    private string posTextFile = "";
    public static string objTextFile = "";



    // Start is called before the first frame update
    void Start()
    {
        // Call the CollectPositionData() Method Once every 1/10th of a second (10Hz)
        InvokeRepeating("CollectPositionData", 0f, 0.1f);
        m_Randomizev2 = GameObject.FindObjectOfType(typeof(Randomizev2)) as Randomizev2;


    }

    void Awake()
    {
        if (!created)
        {
            DontDestroyOnLoad(this.gameObject);
            created = true;
            Debug.Log("Awake: " + this.gameObject);
        }
    }

    IEnumerator sendPosTexttoFile()
    {
        bool successful = true;
        WWWForm form = new WWWForm();
        form.AddField("input", posTextFile);
        form.AddField("filename", ParticipantLog.file_name_pos);
        WWW www = new WWW("http://localhost:9000/OFTreceipt.php", form);

        yield return www;
        if (www.error != null)
        {
            successful = false;
        }
        else
        {
            Debug.Log(www.text);
            successful = true;
        }
    }

    IEnumerator sendObjTexttoFile()
    {
        bool successful = true;
        WWWForm form2 = new WWWForm();
        form2.AddField("input2", objTextFile);
        form2.AddField("filename2", ParticipantLog.file_name_obj);
        WWW www2 = new WWW("http://localhost:9000/OFTreceipt_obj.php", form2);

        /*StreamWriter writedist = File.AppendText(OBJ_FILE_NAME);
        if (new FileInfo(OBJ_FILE_NAME).Length == 0)
        {
            writedist.WriteLine("target_obj, trial_level, start_x, start_z, start_rot_y, end_x, end_z, end_rot_y, " +
                "delta_start, delta_target, run_time, completion_time," +
                "tot_dist, tot_rot_y, sl_dist, efficiency, avg_speed");
        }
        writedist.WriteLine(objTextFile);

        writedist.Close();*/

        yield return www2;
        if (www2.error != null)
        {
            successful = false;
        }
        else
        {
            Debug.Log(www2.text);
            successful = true;
        }


    }

    void CollectPositionData()
    {

        // Every 10 Hz after start, grab Variables
        // Distance from player to target object, and distance from player spawn to current player location

        ++cpdIteration;
        avgSpeed = (fps.m_Speed + sumSpeed) / cpdIteration;
        sumSpeed = fps.m_Speed + sumSpeed;
        float deltaTarget = Vector3.Distance(target.transform.position, fps.transform.position);
        float deltaStart = Vector3.Distance(GameObject.FindWithTag("spawn").transform.position, fps.transform.position);



        // Initiate writing [particpant #]_position.txt, if no data is present, write a header line containing variable names
    /*    StreamWriter sw = File.AppendText(FILE_NAME);
        if (new FileInfo(FILE_NAME).Length == 0)
        {
            sw.WriteLine("pos_x, pos_z, rot_y, run_time, trial_time, target_obj, trial_level, delta_target, " +
                "delta_start, speed, tot_dist, tot_rot_y, target_visible");
        }*/
        
        if (GameObject.FindWithTag("target").name == "Bucket_clean")
        {
            target_visible = GameObject.Find("bucket_low").GetComponent<MeshRenderer>().enabled;
        } else
        {
            target_visible = GameObject.FindWithTag("target").GetComponent<MeshRenderer>().enabled;
        }
        ;

        posTextFile += playerPos.x + "," + playerPos.z + "," +
            playerRot.y + "," +
            Time.time + "," + (Time.time - Randomizev2.startTime) + "," +
            target.name + "," +
            SceneManager.GetActiveScene().name + "," +
            deltaTarget + "," + deltaStart + "," +
            fps.m_Speed + "," + totalDistanceTraveled + "," +
            tdrAngle + ", " + target_visible + "\n";

        /*sw.WriteLine(posTextFile);
        sw.Close();*/
        
        
    }

    void CollectResponseData()
    {
        
        target = GameObject.FindWithTag("target");
        spawn = GameObject.FindWithTag("spawn");
        totalDegreesRotatedY = tdrAngle;


        // Upon response event from participant, record data variables to #_responses:

        float slDist = Vector3.Distance(target.transform.position, spawn.transform.position);

        objTextFile = targetName + "," + SceneManager.GetActiveScene().name + "," +
            spawn.transform.position.x + "," + spawn.transform.position.z + "," +
            spawn.transform.eulerAngles.y + "," +
            fps.transform.position.x + "," + fps.transform.position.z + "," +
            fps.transform.eulerAngles.y + "," +
            Vector3.Distance(spawn.transform.position, fps.transform.position) + "," +
            Vector3.Distance(target.transform.position, fps.transform.position) + "," +
            Time.time + "," + (Time.time - Randomizev2.startTime) + "," +
            totalDistanceTraveled + "," + totalDegreesRotatedY + "," +
            slDist + "," + (totalDistanceTraveled / slDist) + "," + avgSpeed + "\n";

        StartCoroutine(sendObjTexttoFile());
        StartCoroutine(sendPosTexttoFile());
        Debug.Log(objTextFile);

        // Check to see if we are in testing phase (test trials), if so, set trial phase to 2 (uncollected data)
        if(ParticipantLog.trialPhase != 3)
        {
            ParticipantLog.trialPhase = 2;
        }
        
    }


    // Update is called once per frame
    void Update()
    {
        
        fps = FindObjectOfType<FirstPersonController>();
        
        // With each update, obtain necessary data
        // Player position and player rotation 
        playerPos = fps.transform.position;
        playerRot = fps.transform.eulerAngles;
        playerRotAngle = fps.transform.forward;

        // If new trial, assign last position and last rotation to current position and rotation
        if (newTrial)
        {
            spawn = GameObject.FindWithTag("spawn");
            
            lastPosition = spawn.transform.position;
            lastAngle = spawn.transform.forward;
            avgSpeed = 0f;
            sumSpeed = 0f;
            cpdIteration = 0;
            posTextFile = "";
            
            // targetText = GameObject.FindObjectOfType<Text>();
            target = GameObject.FindWithTag("target");
            Debug.Log(target.name);
            targetName = target.name;
            totalDistanceTraveled = 0;
            tdrAngle = 0;
            sumSpeed = 0f;
            avgSpeed = 0f;
            cpdIteration = 0;
            switch (targetName)
            {
                case "Bucket_clean":
                    targetName = "Bucket";
                    break;

                case "cone_clean":
                    targetName = "Cone";
                    break;

                case "chFolding.A_LOD0":
                    targetName = "Chair";
                    break;

            }
            // InvokeRepeating("CollectPositionData", 0f, 0.1f);
            Debug.Log(spawn.transform.position);
            Debug.Log(playerPos);
            // targetText.text = targetName;
            // targetText.color = Color.black;
            newTrial = false;


        }

        // Calculate total degrees rotated since last update, do same for distance. 
        // These will be used in CollectResponseData() and CollectPositionData() methods.

        float angleTrav = Vector3.Angle(playerRotAngle, lastAngle);
        tdrAngle += angleTrav;


        float distTrav = Vector3.Distance(playerPos, lastPosition);
        totalDistanceTraveled += distTrav;
        
        // Update last position and rotation to current rotation for use within the next update
        lastPosition = playerPos;
        lastAngle = playerRotAngle;

        target = GameObject.FindWithTag("target");
       


        // Upon initial trial load, set file name to participant number entered on launch
        if (FILE_NAME == "test" && OBJ_FILE_NAME == "test")
        {
            FILE_NAME = ParticipantLog.user + "_position.csv";
            OBJ_FILE_NAME = ParticipantLog.user + "_trial.csv";
          
            
        }


        if (Input.GetKeyDown(KeyCode.Return))
        {
      
            // Trial phase 2: Learn & Practice trials only. It means that the first phase has passed and the participant pressed the first Enter. This phase asks for confirmation before moving on.
            if (ParticipantLog.trialPhase == 2)
            {
                m_Randomizev2.NextScene();
                



            }
            // Trial phase 1: Learn & Practice trials only. This is where OFT is waiting for the participant to respond with the first Enter press.
            else if (ParticipantLog.trialPhase == 1)
            {
                targetObject = GameObject.FindWithTag("target");
                float distanceToTO = Vector3.Distance(targetObject.transform.position, fps.transform.position);
                
                if (targetObject.name == "Bucket_clean")
                    {
                        object31 = GameObject.Find("bucket_low");
                        object32 = GameObject.Find("rings_low");
                        object31.GetComponent<MeshRenderer>().enabled = true;
                        object32.GetComponent<MeshRenderer>().enabled = true;
    
                    }
                    else
                    {
                        MeshRenderer m = targetObject.GetComponent<MeshRenderer>();
                        m.enabled = true;
                    }
                
                
                if (distanceToTO < radiusThreshold)
                {
                    

                    // targetText.text = "Good Job!";
                    TipboxManager.text_tip = "*** Good Job! Press ENTER to continue to the next trial! ***";


                    CollectResponseData();
                }
                else
                {

                    // targetText.text = "Move closer to the center of the " + targetName + "!";
                    TipboxManager.text_tip = "*** Move closer to the center of the " + targetName + "! ***";
                }

                


            }
            // Check to see if Test trial. Upon response, no feedback (reveal object). 
            // Immediately begin next test trial.
            else if (ParticipantLog.trialPhase == 3)
            {
                CollectResponseData();
                m_Randomizev2.NextScene();
                



            }
        }
    }
}

