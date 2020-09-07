using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class TokenDisplay : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        TextMeshPro textmeshPro = GetComponent<TextMeshPro>();
        textmeshPro.SetText("OFTUCI-" + ParticipantLog.token_OFT);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
