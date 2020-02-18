using System.Collections.Generic;
using UnityEngine;

public class TrialScriptBall : MonoBehaviour
{
    public GameObject Ball;

    // Update is called once per frame
    private void Start()
    {
        Ball.GetComponent<Renderer>().enabled = true;

  
        }
    void Update()
    {

        if (Input.GetKeyDown("p"))
        {
            float distance = Vector3.Distance(Ball.transform.position, transform.position);
            print("Distance to Thing: " + distance);
            Ball.GetComponent<Renderer>().enabled = true;

        }

      
    }
  

    void OnTriggerEnter(Collider other)
    {

        if (Ball.GetComponent<Renderer>().enabled == true)
        {

            if (other.gameObject == Ball)
            {

                other.gameObject.SetActive(false);


            }
        }
    }
}