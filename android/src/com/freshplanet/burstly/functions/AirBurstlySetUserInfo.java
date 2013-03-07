//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.burstly.functions;

import java.util.HashMap;
import java.util.Map;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.burstly.Extension;

public class AirBurstlySetUserInfo implements FREFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		Map<String, String> infos = new HashMap<String, String>();
		FREArray keysArray = (FREArray)args[0];
		FREArray valuesArray = (FREArray)args[1];
		long arrayLength;
		try
		{
			arrayLength = keysArray.getLength();
			String key;
			String value;
			for (int i = 0; i < arrayLength; i++)
			{
				key =  keysArray.getObjectAt((long)i).getAsString();
				value = valuesArray.getObjectAt((long)i).getAsString();
				infos.put(key, value);
			}
		}
		catch (Exception e)
		{
			Extension.log("Error - setUserInfo - Couldn't retrieve Actionscript parameters. Exception message: " + e.getMessage() + ". See \"adb logcat\" for stack trace.");
			e.printStackTrace();
			return null;
		}
		
		Extension.context.setUserInfo(infos);
		
		return null;
	}

}
