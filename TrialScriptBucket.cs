using System.Collections.Generic;
using UnityEngine;

public class TrialScriptBucket : MonoBehaviour
{
    public GameObject Bucket;
    public GameObject object31, object32;

    // Update is called once per frame
    private void Start()
    {
        
        object31 = GameObject.Find("bucket_low");
        object32 = GameObject.Find("rings_low");
        MeshRenderer n = object31.GetComponent<MeshRenderer>();
        MeshRenderer o = object32.GetComponent<MeshRenderer>();
        n.enabled = true;
        o.enabled = true;


    }
    void Update()
    {

        if (Input.GetKeyDown("p"))
        {
            float distance = Vector3.Distance(Bucket.transform.position, transform.position);
            print("Distance to Thing: " + distance);
            

        }


    }


    void OnTriggerEnter(Collider other)
    {

        if (Bucket.GetComponent<Renderer>().enabled == true)
        {

            if (other.gameObject == Bucket)
            {

                other.gameObject.SetActive(false);


            }
        }
    }
}