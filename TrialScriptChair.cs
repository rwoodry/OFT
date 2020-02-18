using System.Collections.Generic;
using UnityEngine;

public class TrialScriptChair : MonoBehaviour
{
    public GameObject Chair;

    // Update is called once per frame
    private void Start()
    {
        Chair.GetComponent<Renderer>().enabled = true;


    }
    void Update()
    {

        if (Input.GetKeyDown("i"))
        {
            float distance = Vector3.Distance(Chair.transform.position, transform.position);
            print("Distance to Thing: " + distance);
            Chair.GetComponent<Renderer>().enabled = true;

        }


    }


    void OnTriggerEnter(Collider other)
    {

        if (Chair.GetComponent<Renderer>().enabled == true)
        {

            if (other.gameObject == Chair)
            {

                other.gameObject.SetActive(false);


            }
        }
    }
}
