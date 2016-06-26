﻿using System;
using System.Xml.Serialization;
using System.Xml;
using System.Collections.Generic;

namespace ArmA_UI_Editor.Code.AddInUtil
{
    [Serializable]
    public class UIElement
    {
        [XmlElement("displayname")]
        public string DisplayName { get; set; }
        [XmlElement("image")]
        public string Image { get; set; }
        [XmlElement("class")]
        public string __ClassPath { get; set; }
        [XmlElement("xaml")]
        public string __XamlPath { get; set; }
        [XmlElement("properties")]
        public string __PropertiesPath { get; set; }
        [XmlElement("events")]
        public List<string> __EventsPath { get; set; }

        [XmlIgnore()]
        public SQF.ClassParser.File ClassFile { get; set; }
        [XmlIgnore()]
        public AddIn Parent { get; set; }
        [XmlIgnore()]
        public Properties Properties { get; private set; }
        [XmlIgnore()]
        public List<Event> Events { get; private set; }

        public UIElement()
        {
            this.DisplayName = default(string);
            this.Image = default(string);
            this.__ClassPath = default(string);
            this.__XamlPath = default(string);
            this.__PropertiesPath = default(string);
            this.Events = new List<Event>();
        }
        
        public void Initialize()
        {
            this.Image = Parent.ThisPath + Image.Replace('/', '\\');
            this.__ClassPath = Parent.ThisPath + __ClassPath.Replace('/', '\\');
            this.__XamlPath = Parent.ThisPath + __XamlPath.Replace('/', '\\');
            this.__PropertiesPath = Parent.ThisPath + __PropertiesPath.Replace('/', '\\');
            this.ClassFile = SQF.ClassParser.File.Load(this.__ClassPath);
            using (var reader = new System.IO.StreamReader(this.__PropertiesPath))
            {
                var x = new XmlSerializer(typeof(Properties));
                var properties = (Properties)x.Deserialize(reader);
                this.Properties = properties;
            }
            foreach (var it in this.__EventsPath)
            {
                var path = System.IO.Path.Combine(Parent.ThisPath, it.TrimStart(new[] { '\\', '/' }));
                List<Event> events = Event.Load(path);
                this.Events.AddRange(events);
            }
        }
    }
}