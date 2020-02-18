using System.Collections.Generic;
using UnityEngine;

public class TrialScriptCone : MonoBehaviour
{
    public GameObject Cone;

    // Update is called once per frame
    private void Start()
    {
        Cone.GetComponent<Renderer>().enabled = true;

  
        }
    void Update()
    {

        if (Input.GetKeyDown("p"))
        {
            float distance = Vector3.Distance(Cone.transform.position, transform.position);
            print("Distance to Thing: " + distance);
            Cone.GetComponent<Renderer>().enabled = true;

        }

      
    }
  

    void OnTriggerEnter(Collider other)
    {

        if (Cone.GetComponent<Renderer>().enabled == true)
        {

            if (other.gameObject == Cone)
            {

                other.gameObject.SetActive(false);


            }
        }
    }
}