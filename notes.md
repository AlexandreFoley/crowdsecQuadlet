- Je vais avoir besoin de customizé l'image un peut: le script d'entré du container ne supporte pas les token pour enregistré l'API...
- Il faut modifier le script docker_start.sh
    - ```
    conf_set_if "$LOCAL_API_URL" '.url = strenv(LOCAL_API_URL)' "$lapi_credentials_path" 
    
    if istrue "$DISABLE_LOCAL_API"; then 
        # we only use the envvars that are actually defined 
        # in case of persistent configuration 
        if [  "$AGENT_USERNAME" != "" ] then;
           conf_set_if "$AGENT_USERNAME" '.login = strenv(AGENT_USERNAME)' "$lapi_credentials_path" 
        fi
        if [  "$AGENT_PASSWORD" != "" ] then;
            conf_set_if "$AGENT_PASSWORD" '.password = strenv(AGENT_PASSWORD)' "$lapi_credentials_path"
        fi
        if [  "$AGENT_AUTO_REGISTRATION_TOKEN" != "" ] then;
            if [  "$AGENT_USERNAME" != "" ] then;
               cscli lapi register --url "$LOCAL_API_URL" --token "$AGENT_AUTO_REGISTRATION_TOKEN" --machine "$AGENT_USERNAME"
            else
                cscli lapi register --url "$LOCAL_API_URL" --token "$AGENT_AUTO_REGISTRATION_TOKEN"
            fi
        fi
    fi 
    ```
    
    - va remplacer 
    ```  
    conf_set_if "$LOCAL_API_URL" '.url = strenv(LOCAL_API_URL)' "$lapi_credentials_path" 
    
    if istrue "$DISABLE_LOCAL_API"; then 
    # we only use the envvars that are actually defined 
    # in case of persistent configuration 
        conf_set_if "$AGENT_USERNAME" '.login = strenv(AGENT_USERNAME)' "$lapi_credentials_path" 
        conf_set_if "$AGENT_PASSWORD" '.password = strenv(AGENT_PASSWORD)' "$lapi_credentials_path" 
    fi ```
    
    - Le dockerfile est dans le dossier (dockerfile.debian)
    - Idéalement, il faut setté le dockerfile sur github de sorte a automergé le mainline docker_start.sh, notifié en cas de conflit, construire un nouvelle image sinon.
        - Check le remote 1/jour