using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;
using System.IO;
using UnityStandardAssets.Characters.FirstPerson;



public class Randomizev2 : MonoBehaviour
{
    // Creating a HashSet of odd numbers 
    HashSet<int> levels = new HashSet<int>();
    private int numlevel = 24;
    private static bool created = false;
    public static int nextLevel = 0;
    string FILE_NAME = "position.txt";
    string OBJ_FILE_NAME = "objdistance.txt";
    public static Vector3 playerStart;
    public static int currentLevel;
    public static float startTime;
    public bool learnTrialsCompleted = false;
    public bool practiceTrialsCompleted = false;
    public int learnTrials = 1;
    public int practiceTrials = 1;
    public static bool OFT_COMPLETE = false;
    private bool instructions = false;
    private bool practiceInstructionsViewed = false;
    private bool testInstructionsViewed = false;


    void Start()
    {

    }

    void LevelPick(){
        // Check to see if Learning trials have been completed, if not, 
        // select the next learning trial in sequential order.

        if (learnTrialsCompleted && practiceTrialsCompleted && testInstructionsViewed)
        {
            ParticipantLog.trialPhase = 3;
            // While levels completed do not reach max trials, randomly select without replacement
            // the next testing trial

            // Display test instructions if they haven't been viewed already

                while (levels.Count != numlevel)
                {
                    int randNum = UnityEngine.Random.Range(1, numlevel+1);
                    //Debug.Log(randNum + " = generated");
                    if (levels.Add(randNum))
                    {
                        nextLevel = randNum + 8;
                        Debug.Log("Trial level: " + randNum + " picked");

                        if (levels.Count == numlevel)
                        {
                            OFT_COMPLETE = true;
                        }
                        break;
                    }
                }
            
            
        } 
        else if (learnTrialsCompleted && !practiceTrialsCompleted && practiceInstructionsViewed)
        {

           
            
                nextLevel = practiceTrials + 4;
                Debug.Log("Practice Level: " + (nextLevel - 4) + " picked");
                practiceTrials += 1;

                if (practiceTrials == 5)
                {
                    practiceTrialsCompleted = true;
                }
            
           
        }
        else if(instructions && !learnTrialsCompleted)
        {
            
            // Sequentially go through each of the four learning trials before beginning 
            // the testing phase
            nextLevel = learnTrials;
            Debug.Log("Learn level: " + nextLevel + " picked");
            learnTrials += 1;

            if (learnTrials == 5)
            {
                learnTrialsCompleted = true;

            }
        } 
        else
        {
            if (!testInstructionsViewed && practiceInstructionsViewed && instructions)
            {
                nextLevel = 36;
                Debug.Log("Test Instructions");
            }
            else if (!testInstructionsViewed && !practiceInstructionsViewed && instructions)
            {
                nextLevel = 35;
                Debug.Log("Practice Instructions");
            }
            else
            {
                nextLevel = 34;
                Debug.Log("Instructions");
            }
            

        }
        
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

    // Update is called once per frame
    void Update()
    {
        // If the current scene is Instructions and the participant presses ENTER, move on to the next scene (Learn Trial 01)
        if (Input.GetKeyDown(KeyCode.Return))
        {
            if (!instructions && SceneManager.GetActiveScene().name == "Instructions")
            {
                instructions = true;
                NextScene();
            }
            else if (!testInstructionsViewed && SceneManager.GetActiveScene().name == "Instructions Test")
            {
                testInstructionsViewed = true;
                NextScene();
            } 
            else if (!practiceInstructionsViewed && SceneManager.GetActiveScene().name == "Instructions Practice")
            {
                practiceInstructionsViewed = true;
                NextScene();
            }
            
        } 
    }

    public void StartPause()
    {
        StartCoroutine(PauseGame());
    }
    public IEnumerator PauseGame()
    {
        
        SceneManager.LoadScene("Fixation");
        yield return new WaitForSeconds(3);
        SceneManager.LoadScene(nextLevel);



    }

    public void NextScene()
    {
        Debug.Log("NS");
        LevelPick();
        StartPause();
        

        

        StreamWriter writelevel = File.AppendText(FILE_NAME);
        writelevel.WriteLine("level " + nextLevel + " loaded");
        writelevel.Close();
        StreamWriter writelevelobj = File.AppendText(OBJ_FILE_NAME);
        writelevelobj.WriteLine("level " + nextLevel + " loaded");
        writelevelobj.Close();

        if (nextLevel == currentLevel)
        {
            TipboxManager.text_tip = "YOU ARE DONE. PRESS Ctrl+P TO EXIT PILOT TEST.";
        } else
        {
            currentLevel = nextLevel;
            TipboxManager.text_tip = "";
            if (currentLevel >= 5 && currentLevel <= 8) { TipboxManager.text_tip = "*** Go to where you believe the target is! ***";  }
        }
       
        startTime = Time.time;
        if (ParticipantLog.trialPhase != 3)
        {
            ParticipantLog.trialPhase = 1;
        }

        LogManager.newTrial = true;
        Debug.Log(LogManager.objTextFile);





    }

}
